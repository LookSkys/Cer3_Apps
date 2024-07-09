import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  //Obtener lista de Tareas
  Stream<QuerySnapshot> horarios() {
    return FirebaseFirestore.instance.collection('Horarios').snapshots();
  }

  Stream<QuerySnapshot> usuarios() {
    return FirebaseFirestore.instance.collection('Usuarios').snapshots();
  }
}
