import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  Stream<QuerySnapshot> horarios() {
    return FirebaseFirestore.instance
        .collection('Horarios')
        .orderBy('titulo')
        .snapshots();
  }

  Future<void> crearRutina(
    String titulo,
    String descripcion,
    String duracion,
    String nivel,
    List<String> ejercicios,
    String creadorId,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('Rutinas').add({
        'titulo': titulo,
        'descripcion': descripcion,
        'duracion': duracion,
        'nivel': nivel,
        'ejercicios': ejercicios,
        'creador': creadorId, 
        'fecha de creación': Timestamp.now(),
      });
    } catch (e) {
      print('Error al crear la rutina: $e');
      throw Exception('No se pudo crear la rutina');
    }
  }

  Future<String> getUserName(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        return userSnapshot[
            'nombre']; 
      } else {
        return 'Usuario Desconocido';
      }
    } catch (e) {
      print('Error obteniendo el nombre del usuario: $e');
      return 'Usuario Desconocido';
    }
  }

  Stream<QuerySnapshot> usuarios() {
    return FirebaseFirestore.instance.collection('Usuarios').snapshots();
  }

  Stream<QuerySnapshot> rutinas() {
    return FirebaseFirestore.instance.collection('Rutinas').snapshots();
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
