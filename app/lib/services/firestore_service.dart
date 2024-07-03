import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  //Obtener lista de Tareas
  Stream<QuerySnapshot> tareas() {
    return FirebaseFirestore.instance.collection('tareas').snapshots();
  }

  Stream<QuerySnapshot> categorias() {
    return FirebaseFirestore.instance.collection('categorias').snapshots();
  }
}
