import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  //Obtener lista de Tareas
  Stream<QuerySnapshot> horarios() {
    return FirebaseFirestore.instance
        .collection('Horarios')
        .orderBy('titulo')
        .snapshots();
  }

  Stream<QuerySnapshot> usuarios() {
    return FirebaseFirestore.instance.collection('Usuarios').snapshots();
  }

  Future<void> enrollUser(DocumentSnapshot horario, User user) async {
    final enrolmentRef =
        horario.reference.collection('enrolamiento').doc(user.uid);

    final enrolmentSnapshot = await enrolmentRef.get();
    if (!enrolmentSnapshot.exists) {
      final enrolledSnapshot =
          await horario.reference.collection('enrolamiento').get();
      int enrolledCount = enrolledSnapshot.docs.length;
      int maxCapacity = horario['cap_max'];

      if (enrolledCount < maxCapacity) {
        await enrolmentRef.set({
          'user_id': user.uid,
          'user_name': user.displayName,
          'user_email': user.email,
          'enrolment_time': FieldValue.serverTimestamp(),
        });
      } else {
        throw Exception('Capacidad máxima alcanzada');
      }
    } else {
      throw Exception('Ya estás inscrito en este horario');
    }
  }

  Future<void> unenrollUser(DocumentSnapshot horario, User user) async {
    final enrolmentRef =
        horario.reference.collection('enrolamiento').doc(user.uid);

    final enrolmentSnapshot = await enrolmentRef.get();
    if (enrolmentSnapshot.exists) {
      await enrolmentRef.delete();
    } else {
      throw Exception('No estás inscrito en este horario');
    }
  }
}
