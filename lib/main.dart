import 'package:desperdicio_cero/pages/home.dart';
import 'package:desperdicio_cero/pages/lista_compra.dart';
import 'package:desperdicio_cero/pages/primera_pagina.dart';
import 'package:desperdicio_cero/pages/productos.dart';
import 'package:desperdicio_cero/pages/lista_productos.dart';
import 'package:desperdicio_cero/pages/profile.dart';
import 'package:desperdicio_cero/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;

void main() {
  sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi;
  runApp(MyApp());
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
