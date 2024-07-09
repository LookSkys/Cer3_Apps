import 'package:app/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _signOut(BuildContext context) async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _enrollUser(
      BuildContext context, DocumentSnapshot horario) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final enrollementRef =
          horario.reference.collection('enrolamiento').doc(user.uid);
      final enrollementSnapshot = await enrollementRef.get();

      if (!enrollementSnapshot.exists) {
        await enrollementRef.set({
          'user_id': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Inscripción exitosa')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ya estás inscrito en este horario')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Horarios'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
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

                  return ListTile(
                    title: Text(
                        '${horario['titulo']} - ${startTime.format(context)} a ${endTime.format(context)}'),
                    trailing: Text('$enrolledCount / $maxCapacity'),
                    onTap: () => _enrollUser(context, horario),
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
