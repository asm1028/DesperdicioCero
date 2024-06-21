import 'package:desperdiciocero/firebase_options.dart';
import 'package:desperdiciocero/pages/home.dart';
import 'package:desperdiciocero/pages/lista_compra.dart';
import 'package:desperdiciocero/pages/primera_pagina.dart';
import 'package:desperdiciocero/pages/productos.dart';
import 'package:desperdiciocero/pages/lista_productos.dart';
import 'package:desperdiciocero/pages/profile.dart';
import 'package:desperdiciocero/pages/user_settings.dart';
import 'package:desperdiciocero/pages/productos_comprados.dart';
import 'package:desperdiciocero/pages/expiration_date_recognizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Habilita la persistencia de datos en Firestore para que la app funcione sin conexión
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  await initializeUserToken(); // Llama a la función para inicializar el token del usuario
  await requestPermissions(); // Solicita los permisos necesarios antes de iniciar la app

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

// Función para solicitar permisos
Future<void> requestPermissions() async {
  final status = await Permission.camera.request();
  if (status.isGranted) {
    // Permiso concedido
    print("Permiso de cámara concedido");
  } else if (status.isDenied) {
    // Permiso denegado
    print("Permiso de cámara denegado");
  } else if (status.isPermanentlyDenied) {
    // El usuario ha denegado permanentemente el permiso; abra la configuración de la app
    openAppSettings();
  }
  // Aquí puedes añadir más solicitudes de permisos según sea necesario
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Rutas para poder viajar entre las diferentes páginas de la aplicación
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
        '/recognizeExpirationDate': (context) => ExpirationDateRecognizer(),
      },

      // Localización de la aplicación para que salgan los textos en español
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('es', ''), // Español
      ],
    );
  }
}