import 'package:desperdiciocero/firebase_options.dart';
import 'package:desperdiciocero/pages/home.dart';
import 'package:desperdiciocero/pages/lista_compra.dart';
import 'package:desperdiciocero/pages/primera_pagina.dart';
import 'package:desperdiciocero/pages/productos.dart';
import 'package:desperdiciocero/pages/lista_productos.dart';
import 'package:desperdiciocero/pages/profile.dart';
import 'package:desperdiciocero/pages/user_settings.dart';
import 'package:desperdiciocero/pages/productos_comprados.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeUserToken(); // Llama a la función para inicializar el token del usuario

  runApp(const MyApp());
}

// Función para generar y almacenar el token del usuario si no existe
Future<void> initializeUserToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? userToken = prefs.getString('userToken');
  
  if (userToken == null) {
    var uuid = Uuid();
    userToken = uuid.v4(); // Genera un UUID
    await prefs.setString('userToken', userToken);
    
    // Guarda el token en la base de datos bajo la colección 'users'
    await firestore.collection('users').doc(userToken).set({
      'token': userToken,
      'created_at': FieldValue.serverTimestamp(),
    });
    
    print("User Token: $userToken");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PrimeraPagina(),
      routes: {
        'primera_pagina': (context) => PrimeraPagina(),
        '/home': (context) => Home(),
        '/productos': (context) => Productos(),
        '/listaProductos': (context) => ListaProductos(),
        '/settings': (context) => UserSettings(),
        '/profile': (context) => Profile(),
        '/listaCompra': (context) => ListaCompra(),
        '/productosComprados': (context) => ProductosComprados(),
      },
    );
  }
}