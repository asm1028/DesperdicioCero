import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // Inicialización de Firebase
  await Firebase.initializeApp();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference productosCollection = firestore.collection('productos');

  await productosCollection.add({
    'nombre': 'Producto 1',
    'caducidad': '8/5/2024',
  });

  QuerySnapshot querySnapshot = await productosCollection.get();
  for (var doc in querySnapshot.docs) {
    print('Nombre: ${(doc.data() as Map<String, dynamic>)['nombre']}');
    print('Caducidad: ${(doc.data() as Map<String, dynamic>)['caducidad']}');
  }
}