import 'package:app/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tareas')),
      body: StreamBuilder(
        stream: FirestoreService().tareas(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot tareas = snapshot.data!.docs[index];
              List<dynamic> descripcion = tareas['descripcion'];
              return ListTile(
                title: Text(tareas['titulo']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      descripcion.map((item) => Text(item.toString())).toList(),
                ),
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}
