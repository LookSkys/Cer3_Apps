import 'package:app/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
      backgroundColor: Color(0xff091819), // Fondo negro
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

              // Formatea la fecha de creación
              var formattedFechaCreacion =
                  DateFormat.yMd().format(fechaCreacion.toDate());

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(0xffD99058), // Fondo naranja
                  borderRadius: BorderRadius.circular(10), // Bordes redondeados
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
                    style: TextStyle(color: Colors.black), // Texto negro
                  ),
                  subtitle: Text(
                    descripcion,
                    style:
                        TextStyle(color: Colors.black54), // Texto gris oscuro
                  ),
                  trailing: _getIconForLevel(nivel),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleRutinaScreen(
                          rutina: rutina,
                          fechaCreacion:
                              formattedFechaCreacion, // Pasa la fecha formateada
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
            // Acción a realizar al presionar el botón flotante
          },
          backgroundColor: Colors.orange, // Color de fondo naranja
          child: Icon(Icons.add, color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(30.0), // Radio de borde circular
            side: BorderSide(color: Colors.black),
          ) // Icono de añadir en negro
          ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .endFloat, // Ubicación en la esquina inferior derecha
    );
  }
}

class DetalleRutinaScreen extends StatelessWidget {
  final DocumentSnapshot rutina;
  final String fechaCreacion; // Recibe la fecha formateada como argumento

  const DetalleRutinaScreen(
      {Key? key, required this.rutina, required this.fechaCreacion})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var creador = rutina['creador'];
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
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white), // Fondo negro
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              color: Color(0xffD99058),
              child: ListTile(
                leading: Icon(Icons.person, color: Colors.white),
                title: Text(
                  'Creador',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  creador,
                  style: TextStyle(color: Colors.black87),
                ),
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
                  fechaCreacion, // Muestra la fecha formateada
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
                width: 500,
                height: 50, // Alto del contenedor
                decoration: BoxDecoration(
                  color: Colors.red, // Color de fondo del contenedor
                  shape: BoxShape.rectangle, // Forma circular del contenedor
                ),
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.black),
                  onPressed: () {
                    // Acción a realizar al presionar el botón de borrar
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
