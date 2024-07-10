import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff091819),
      appBar: AppBar(
        title: Text(
          'Agregar Rutina',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff091819),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xff1e1e1e),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un título';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xff1e1e1e),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese una descripción';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _duracionController,
                decoration: InputDecoration(
                  labelText: 'Duración',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xff1e1e1e),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese una duración';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
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
                decoration: InputDecoration(
                  labelText: 'Nivel',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xff1e1e1e),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                dropdownColor: Color(0xff1e1e1e),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, seleccione un nivel';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ejercicioController,
                      decoration: InputDecoration(
                        labelText: 'Ejercicio',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Color(0xff1e1e1e),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
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
                    icon: Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      if (_ejercicioController.text.isNotEmpty) {
                        _agregarEjercicio(_ejercicioController.text);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _ejercicios.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _ejercicios[index],
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _ejercicios.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _guardarRutina,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffD99058),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Guardar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
