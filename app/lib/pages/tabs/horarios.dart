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
      backgroundColor: Color(0xff091819), 
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
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange, 
                        borderRadius:
                            BorderRadius.circular(10), 
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
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              horario['titulo'],
                              style: TextStyle(
                                color: Colors.black, 
                                fontWeight: FontWeight.bold, 
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.access_time, color: Colors.black54),
                                SizedBox(
                                    width:
                                        4), 
                                Text(
                                  '${startTime.format(context)} a ${endTime.format(context)}',
                                  style: TextStyle(
                                      color:
                                          Colors.black54), 
                                ),
                              ],
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Icon(Icons.people, color: Colors.black54),
                            SizedBox(
                                width: 4), 
                            Text(
                              'Capacidad máxima: $maxCapacity',
                              style: TextStyle(
                                  color: Colors.black54), 
                            ),
                          ],
                        ),
                        trailing: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.orange), // Circular negro
                        ),
                      ),
                    );
                  }

                  int enrolledCount = enrolledSnapshot.data!.docs.length;
                  bool isEnrolled = enrolledSnapshot.data!.docs
                      .any((doc) => doc.id == _auth.currentUser?.uid);

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Color(0xffD99058), 
                      borderRadius:
                          BorderRadius.circular(10), 
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
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            horario['titulo'],
                            style: TextStyle(
                              color: Colors.black, 
                              fontWeight: FontWeight.bold, 
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.black54),
                              SizedBox(
                                  width:
                                      4), 
                              Text(
                                '${startTime.format(context)} a ${endTime.format(context)}',
                                style: TextStyle(
                                    color: Colors.black54), 
                              ),
                            ],
                          ),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Icon(Icons.people, color: Colors.black54),
                          SizedBox(
                              width: 4), 
                          Text(
                            '$enrolledCount / $maxCapacity',
                            style: TextStyle(
                                color: Colors.black), 
                          ),
                        ],
                      ),
                      trailing: isEnrolled
                          ? ElevatedButton(
                              onPressed: () => _unenrollUser(horario, context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black, 
                              ),
                              child: Text(
                                'Desinscribirse',
                                style: TextStyle(
                                    color: Color(0xffD99058)), 
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () => _enrollUser(horario, context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black, 
                              ),
                              child: Text(
                                'Inscribirse',
                                style: TextStyle(
                                    color: Colors.white), 
                              ),
                            ),
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
