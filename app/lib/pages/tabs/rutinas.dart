import 'package:app/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RutinasScreen extends StatelessWidget {
  const RutinasScreen({Key? key}) : super(key: key);

  Icon _getIconForLevel(String nivel) {
    switch (nivel) {
      case 'Principiante':
        return Icon(MdiIcons.emoticonHappy, color: Colors.black);
      case 'Intermedio':
        return Icon(MdiIcons.emoticonNeutral, color: Colors.black);
      case 'Avanzado':
        return Icon(MdiIcons.skull, color: Colors.black);
      default:
        return Icon(Icons.help_outline, color: Colors.black);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff091819), 
      body: StreamBuilder(
        stream: FirestoreService().rutinas(),
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
              var descripcion = rutina['descripcion'];
              var fechaCreacion = rutina['fecha de creación'];
              var nivel = rutina['nivel'];
              var titulo = rutina['titulo'];

             
              var formattedFechaCreacion =
                  DateFormat.yMd().format(fechaCreacion.toDate());

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(0xffD99058), 
                  borderRadius: BorderRadius.circular(10), 
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: Colors.black),
                ),
                child: ListTile(
                  title: Text(
                    titulo,
                    style: TextStyle(color: Colors.black), 
                  ),
                  subtitle: Text(
                    descripcion,
                    style:
                        TextStyle(color: Colors.black54), 
                  ),
                  trailing: _getIconForLevel(nivel),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleRutinaScreen(
                          rutina: rutina,
                          fechaCreacion:
                              formattedFechaCreacion, 
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/agregarRutina');
          },
          backgroundColor: Colors.orange, 
          child: Icon(Icons.add, color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(30.0), 
            side: BorderSide(color: Colors.black),
          ) 
          ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .endFloat, 
    );
  }
}

void _confirmarEliminacion(BuildContext context, String rutinaId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xff091819),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 10),
            Text(
              'Confirmar Eliminación',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar esta rutina?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('Rutinas')
                  .doc(rutinaId)
                  .delete()
                  .then((_) {
                Navigator.of(context).pop(); 
                Navigator.of(context).pop(); 
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Eliminar'),
          ),
        ],
      );
    },
  );
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
    var descripcion = rutina['descripcion'];
    var duracion = rutina['duracion'];
    var ejercicios = rutina['ejercicios'];
    var nivel = rutina['nivel'];
    var titulo = rutina['titulo'];

    return Scaffold(
      backgroundColor: Color(0xff091819),
      appBar: AppBar(
        title: Text(
          titulo,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff091819),
        iconTheme: IconThemeData(color: Colors.white), 
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              color: Color(0xffD99058),
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Usuarios')
                    .doc(rutina['creador'])
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    String creadorNombre =
                        snapshot.data?['nombre'] ?? 'Usuario Desconocido';
                    return ListTile(
                      leading: Icon(Icons.person, color: Colors.white),
                      title: Text(
                        'Creador',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        creadorNombre,
                        style: TextStyle(color: Colors.black87),
                      ),
                    );
                  }
                },
              ),
            ),
            Divider(color: Colors.white54),
            Card(
              color: Color(0xffD99058),
              child: ListTile(
                leading: Icon(Icons.description, color: Colors.white),
                title: Text(
                  'Descripción',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  descripcion,
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ),
            Divider(color: Colors.white54),
            Card(
              color: Color(0xffD99058),
              child: ListTile(
                leading: Icon(Icons.timer, color: Colors.white),
                title: Text(
                  'Duración',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  duracion,
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ),
            Divider(color: Colors.white54),
            Card(
              color: Color(0xffD99058),
              child: ListTile(
                leading: Icon(Icons.bar_chart, color: Colors.white),
                title: Text(
                  'Nivel',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  nivel,
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ),
            Divider(color: Colors.white54),
            Card(
              color: Color(0xffD99058),
              child: ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.white),
                title: Text(
                  'Fecha de creación',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  fechaCreacion, 
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ),
            Divider(color: Colors.white54),
            Card(
              color: Color(0xffD99058),
              child: ListTile(
                leading: Icon(Icons.fitness_center, color: Colors.white),
                title: Text(
                  'Ejercicios',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ejercicios.map<Widget>((ejercicio) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.check, color: Colors.white),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ejercicio,
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Container(
                width: double.infinity,
                height: 50, 
                decoration: BoxDecoration(
                  color: Colors.red, 
                  shape: BoxShape.rectangle, 
                ),
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    _confirmarEliminacion(context, rutina.id);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
