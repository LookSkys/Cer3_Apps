import 'package:app/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Horarios')),
      body: StreamBuilder(
        stream: FirestoreService().horarios(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot horario = snapshot.data!.docs[index];
              DateTime startDateTime = horario['hora_inicio'].toDate();
              DateTime endDateTime = horario['hora_fin'].toDate();
              TimeOfDay startTime = TimeOfDay(
                  hour: startDateTime.hour, minute: startDateTime.minute);
              TimeOfDay endTime =
                  TimeOfDay(hour: endDateTime.hour, minute: endDateTime.minute);

              int maxCapacity = horario['cap_max'];

              return StreamBuilder(
                stream:
                    horario.reference.collection('enrolamiento').snapshots(),
                builder:
                    (context, AsyncSnapshot<QuerySnapshot> enrolledSnapshot) {
                  if (!enrolledSnapshot.hasData) {
                    return ListTile(
                      title: Text(
                          '${horario['titulo']} - ${startTime.format(context)} a ${endTime.format(context)}'),
                      subtitle: Text('Capacidad máxima: $maxCapacity'),
                      trailing: CircularProgressIndicator(),
                    );
                  }

                  int enrolledCount = enrolledSnapshot.data!.docs.length;

                  return ListTile(
                    title: Text(
                        '${horario['titulo']} - ${startTime.format(context)} a ${endTime.format(context)}'),
                    trailing: Text('$enrolledCount / $maxCapacity'),
                    onTap: () {},
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
