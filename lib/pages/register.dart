import 'package:desperdiciocero/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clase de pantalla de registro.
///
/// Esta clase es un StatefulWidget que representa la pantalla de registro en la aplicación.
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

/// Clase de estado de la pantalla de registro.
class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String name = '';

  /// Función para registrar un usuario.
  ///
  /// Esta función valida el formulario y realiza las siguientes acciones:
  /// - Verifica si el correo electrónico ya está registrado en la base de datos.
  /// - Si el correo no está registrado, crea un nuevo usuario en Firebase Auth.
  /// - Obtiene el token de usuario desde SharedPreferences.
  /// - Guarda los datos del usuario en Firestore sin sobrescribir los datos existentes.
  /// - Navega a la pantalla de perfil.
  /// - Si ocurre un error durante el registro, muestra un diálogo de error.
  /// - Si el correo ya está registrado, muestra un diálogo de error.
  void register() async {
    if (_formKey.currentState!.validate()) {
      // Verifica si el correo ya está registrado
      final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

      if (result.docs.isEmpty) {
        try {
          // Crea usuario en Firebase Auth
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          // Obtiene el userToken desde SharedPreferences
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          String? userToken = prefs.getString('userToken');

          // Guarda los datos del usuario en Firestore sin actualizar los datos que ya existían
          await FirebaseFirestore.instance.collection('users').doc(userToken).set({
            'name': name,
            'email': email,
          }, SetOptions(merge: true));  // Se usa merge para no sobrescribir campos existentes

          // Se vuelve a la pantalla de perfil
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Profile()),
          );
        } catch (e) {
          print('Error en el registro: $e');
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error de Registro'),
              content: Text('No se pudo registrar. Por favor intente nuevamente o vuelva más tarde.'),
              actions: [
                TextButton(
                  child: Text('Continuar'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        }
      } else {
        // Aparece este mensaje de error si el correo ya está registrado
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Ya existe un usuario con ese correo electrónico.'),
            actions: [
              TextButton(
                child: Text('Continuar'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registro de Usuario',
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
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Nombre'),
                        validator: (value) => value!.isEmpty ? 'Ingrese un nombre' : null,
                        onChanged: (value) => setState(() => name = value),
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Correo electrónico'),
                        validator: (value) => !value!.contains('@') || !value.contains('.') ? 'Ingrese un correo válido' : null,
                        onChanged: (value) => setState(() => email = value),
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Contraseña'),
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Ingrese una contraseña';
                          } else if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                        onChanged: (value) => setState(() => password = value),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: register,
                        child: Text('Registrarse'),
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
