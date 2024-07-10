import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RutinasScreen extends StatelessWidget {
  const RutinasScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rutinas'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Rutinas').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var rutina = snapshot.data!.docs[index];
              var formattedFechaCreacion =
                  DateFormat.yMd().format(rutina['fecha de creación'].toDate());

              return ListTile(
                title: Text(rutina['titulo']),
                subtitle: Text(rutina['descripcion']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(rutina['nivel']),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _confirmarEliminacion(context, rutina.id);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalleRutinaScreen(
                        rutina: rutina,
                        fechaCreacion: formattedFechaCreacion,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AgregarRutinaScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _confirmarEliminacion(BuildContext context, String rutinaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar esta rutina?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('Rutinas').doc(rutinaId).delete();
                Navigator.of(context).pop();
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}

class DetalleRutinaScreen extends StatelessWidget {
  final DocumentSnapshot rutina;
  final String fechaCreacion;

  const DetalleRutinaScreen({
    Key? key,
    required this.rutina,
    required this.fechaCreacion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var ejercicios = rutina['ejercicios'];

    return Scaffold(
      appBar: AppBar(
        title: Text(rutina['titulo']),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('Usuarios').doc(rutina['creador']).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                String creadorNombre = snapshot.data?['nombre'] ?? 'Usuario Desconocido';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Creador: $creadorNombre'),
                    SizedBox(height: 8),
                    Text('Descripción: ${rutina['descripcion']}'),
                    SizedBox(height: 8),
                    Text('Duración: ${rutina['duracion']}'),
                    SizedBox(height: 8),
                    Text('Nivel: ${rutina['nivel']}'),
                    SizedBox(height: 8),
                    Text('Fecha de creación: $fechaCreacion'),
                    SizedBox(height: 8),
                    Text('Ejercicios:'),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List<Widget>.from(ejercicios.map((ejercicio) {
                        return Text('- $ejercicio');
                      })),
                    ),
                  ],
                );
              }
            }
          },
        ),
      ),
    );
  }
}

class AgregarRutinaScreen extends StatefulWidget {
  @override
  _AgregarRutinaScreenState createState() => _AgregarRutinaScreenState();
}

class _AgregarRutinaScreenState extends State<AgregarRutinaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _duracionController = TextEditingController();
  String _nivelValue = 'Principiante';
  final TextEditingController _ejercicioController = TextEditingController();
  List<String> _ejercicios = [];

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _duracionController.dispose();
    _ejercicioController.dispose();
    super.dispose();
  }

  void _agregarEjercicio(String ejercicio) {
    setState(() {
      _ejercicios.add(ejercicio);
      _ejercicioController.clear();
    });
  }

  void _guardarRutina() {
    if (_formKey.currentState!.validate()) {
      // Obtener el usuario actual
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        FirebaseFirestore.instance.collection('Rutinas').add({
          'titulo': _tituloController.text,
          'descripcion': _descripcionController.text,
          'duracion': _duracionController.text,
          'nivel': _nivelValue,
          'ejercicios': _ejercicios,
          'creador': user.uid,
          'fecha de creación': Timestamp.now(),
        });
        Navigator.pop(context);
      } else {
        // Manejar el caso en el que el usuario no esté autenticado
        // Esto debería ser controlado en la lógica de tu aplicación
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Rutina'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un título';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese una descripción';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _duracionController,
                decoration: InputDecoration(labelText: 'Duración'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese una duración';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _nivelValue,
                onChanged: (String? value) {
                  setState(() {
                    _nivelValue = value!;
                  });
                },
                items: <String>['Principiante', 'Intermedio', 'Avanzado']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Nivel'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, seleccione un nivel';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text('Ejercicios'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ejercicioController,
                      decoration: InputDecoration(labelText: 'Ejercicio'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          if (_ejercicios.isEmpty) {
                            return 'Por favor, ingrese un ejercicio';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      if (_ejercicioController.text.isNotEmpty) {
                        _agregarEjercicio(_ejercicioController.text);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _ejercicios.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_ejercicios[index]),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _ejercicios.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _guardarRutina,
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
