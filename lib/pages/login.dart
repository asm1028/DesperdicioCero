import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:desperdiciocero/pages/primera_pagina.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  void login() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Autenticar el usuario con Firebase Auth y no almacenar el resultado
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Busca el userToken en Firestore basado en el email
        var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

        if (userDoc.docs.isNotEmpty) {
          String userToken = userDoc.docs.first.data()['userToken'] as String;

          // Guardar el userToken en SharedPreferences
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userToken', userToken);

          // Navegar al perfil del usuario o a la pantalla principal
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PrimeraPagina()),
          );
        } else {
          showError('No se encontró el usuario.');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          showError('No se encontró cuenta con ese correo electrónico.');
        } else if (e.code == 'wrong-password') {
          showError('La contraseña es incorrecta.');
        } else {
          showError('Error al iniciar sesión, por favor intente nuevamente más tarde y cuando tenga conexión a internet en caso de no tenerlo.');
        }
      } catch (e) {
        showError('Error al iniciar sesión, por favor intente nuevamente más tarde y cuando tenga conexión a internet en caso de no tenerlo.');
      }
    }
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Iniciar sesión',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[400],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            margin: EdgeInsets.only(top: 150.0),
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Correo electrónico'),
                        validator: (value) => value!.isEmpty ? 'Ingrese un correo' : null,
                        onChanged: (value) => setState(() => email = value),
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Contraseña'),
                        obscureText: true,
                        validator: (value) => value!.isEmpty || value.length < 6 ? 'Contraseña muy corta' : null,
                        onChanged: (value) => setState(() => password = value),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: login,
                        child: Text('Iniciar sesión'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
