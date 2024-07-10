import 'package:app/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Horarios extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _enrollUser(
      DocumentSnapshot horario, BuildContext context) async {
    final user = _auth.currentUser;

    if (user != null) {
      try {
        await FirestoreService().enrollUser(horario, user);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Inscripción exitosa'),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Inicia sesión para inscribirte'),
      ));
    }
  }

  Future<void> _unenrollUser(
      DocumentSnapshot horario, BuildContext context) async {
    final user = _auth.currentUser;

    if (user != null) {
      try {
        await FirestoreService().unenrollUser(horario, user);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Desinscripción exitosa'),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Inicia sesión para desinscribirte'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Horarios'),
      ),
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
                  bool isEnrolled = enrolledSnapshot.data!.docs
                      .any((doc) => doc.id == _auth.currentUser?.uid);

                  return ListTile(
                    title: Text(
                        '${horario['titulo']} - ${startTime.format(context)} a ${endTime.format(context)}'),
                    subtitle: Text('$enrolledCount / $maxCapacity'),
                    trailing: isEnrolled
                        ? ElevatedButton(
                            onPressed: () => _unenrollUser(horario, context),
                            child: Text('Desinscribirse'),
                          )
                        : ElevatedButton(
                            onPressed: () => _enrollUser(horario, context),
                            child: Text('Inscribirse'),
                          ),
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
