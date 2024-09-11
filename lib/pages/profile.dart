import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:desperdiciocero/pages/login.dart';
import 'package:desperdiciocero/pages/primera_pagina.dart';
import 'package:desperdiciocero/pages/register.dart';

class Profile extends StatefulWidget {
  Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String greeting = '';
  bool hasName = false;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoggedInState();
    loadUserData();
  }

  void checkLoggedInState() async {
    var user = FirebaseAuth.instance.currentUser;
    setState(() {
      isLoggedIn = user != null;
    });
  }

  /// Carga los datos del usuario.
  ///
  /// Este método asincrónico se encarga de cargar los datos del usuario desde las preferencias compartidas y la base de datos Firestore.
  /// Primero, obtiene el token de usuario desde las preferencias compartidas.
  /// Luego, utiliza el token para obtener el documento de usuario correspondiente desde la colección 'users' en Firestore.
  /// Si el documento existe, verifica si contiene la clave 'name'.
  /// Si contiene la clave 'name', actualiza el estado del widget con el saludo personalizado y establece la flag 'hasName' en verdadero.
  /// Si el documento no contiene la clave 'name', establece el estado del widget con un mensaje de bienvenida genérico.
  /// Si el token de usuario es nulo, no se realiza ninguna acción.
  Future<void> loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('userToken');
    if (userToken != null) {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(userToken).get();
      if (userDoc.exists && userDoc.data()!.containsKey('name')) {
        setState(() {
          greeting = 'Hola, ${userDoc.data()!['name']}';
          hasName = true;
        });
      }
    }
    if (!hasName) {
      setState(() {
        greeting = '¿Quieres iniciar sesión para cargar los productos guardados o registrarte para guardar los productos actuales?';
      });
    }
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? backupToken = prefs.getString('backupToken');

    if (backupToken != null && backupToken.isNotEmpty) {
      await prefs.setString('userToken', backupToken);
    } else {
      String newUserToken = Uuid().v4();
      await prefs.setString('userToken', newUserToken);
      await FirebaseFirestore.instance.collection('users').doc(newUserToken).set({
        'userToken': newUserToken,
        'created_at': FieldValue.serverTimestamp(),
      });
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PrimeraPagina()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de Usuario', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[400],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 30), // Añadido para crear más espacio entre la parte superior y el texto
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                greeting,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 50),  // Añadido para crear más espacio entre el texto y los botones
            Card(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Acciones de usuario', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    if (!isLoggedIn) ...[
                      ElevatedButton.icon(
                        icon: Icon(Icons.login, size: 24),
                        label: Text('Iniciar sesión', style: TextStyle(fontSize: 16)),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen())),
                        style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: Icon(Icons.app_registration, size: 24),
                        label: Text('Registrarse', style: TextStyle(fontSize: 16)),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen())),
                        style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                      ),
                    ] else ...[
                      ElevatedButton.icon(
                        icon: Icon(Icons.logout),
                        label: Text('Cerrar sesión', style: TextStyle(fontSize: 16)),
                        onPressed: signOut,
                        style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
