import 'package:desperdicio_cero/firebase_options.dart';
import 'package:desperdicio_cero/pages/home.dart';
import 'package:desperdicio_cero/pages/lista_compra.dart';
import 'package:desperdicio_cero/pages/primera_pagina.dart';
import 'package:desperdicio_cero/pages/productos.dart';
import 'package:desperdicio_cero/pages/lista_productos.dart';
import 'package:desperdicio_cero/pages/profile.dart';
import 'package:desperdicio_cero/pages/settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );
  runApp(const MyApp());
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
        '/settings': (context) => Settings(),
        '/profile': (context) => Profile(),
        '/listaCompra': (context) => ListaCompra(),
      },
    );
  }
}
