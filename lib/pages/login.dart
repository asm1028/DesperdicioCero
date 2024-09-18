import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:desperdiciocero/pages/primera_pagina.dart';

/// Clase que representa la pantalla de inicio de sesión.
///
/// Esta clase es un StatefulWidget que permite crear un estado mutable para la pantalla de inicio de sesión.
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

/// Clase que representa el estado de la página deL Login.
class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  /// Realiza el inicio de sesión del usuario.
  ///
  /// Este método valida el formulario actual y, si es válido, intenta autenticar al usuario utilizando Firebase Auth.
  /// Si la autenticación es exitosa, busca el `userToken` correspondiente al correo electrónico del usuario en Firestore.
  /// Si se encuentra un documento de usuario correspondiente, guarda el `userToken` en SharedPreferences.
  /// Luego, navega a la página de perfil del usuario o a la pantalla principal.
  /// Si no se encuentra ningún documento de usuario correspondiente, muestra un mensaje de error.
  /// Si se produce un error durante el inicio de sesión, muestra un mensaje de error genérico.
  ///
  /// Ejemplo de uso:
  ///
  /// ```dart
  /// login();
  /// ```
  ///
  /// Nota: Este método debe ser llamado dentro de un widget que tenga acceso al contexto.
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

  /// Muestra un diálogo de error con el mensaje proporcionado.
  ///
  /// Muestra un diálogo de error con un título "Error" y el mensaje especificado.
  /// El diálogo contiene un botón "OK" que cierra el diálogo al ser presionado.
  ///
  /// Parámetros:
  ///   - [message]: El mensaje de error a mostrar en el diálogo.
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
