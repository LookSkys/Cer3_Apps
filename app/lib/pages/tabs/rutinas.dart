import 'package:app/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importa intl para usar DateFormat

class RutinasScreen extends StatelessWidget {
  const RutinasScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                var creador = rutina['creador'];
                var descripcion = rutina['descripcion'];
                var duracion = rutina['duracion'];
                var ejercicios = rutina['ejercicios'];
                var fechaCreacion = rutina['fecha de creación'];
                var nivel = rutina['nivel'];
                var titulo = rutina['titulo'];

                // Formatea la fecha de creación
                var formattedFechaCreacion =
                    DateFormat.yMd().format(fechaCreacion.toDate());

                return ListTile(
                  title: Text(titulo),
                  subtitle: Text(descripcion),
                  trailing: Text(nivel),
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
                );
              },
            );
          }),
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
      appBar: AppBar(
        title: Text(titulo),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Creador: $creador'),
            SizedBox(height: 8),
            Text('Descripción: $descripcion'),
            SizedBox(height: 8),
            Text('Duración: $duracion'),
            SizedBox(height: 8),
            Text('Nivel: $nivel'),
            SizedBox(height: 8),
            Text(
                'Fecha de creación: $fechaCreacion'), // Muestra la fecha formateada
            SizedBox(height: 8),
            Text('Ejercicios:'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ejercicios.map<Widget>((ejercicio) {
                return Text('- $ejercicio');
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
