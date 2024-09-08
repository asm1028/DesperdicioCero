import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String name = '';

  void register() async {
    if (_formKey.currentState!.validate()) {
      // Verificar si el correo ya está registrado
      final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

      if (result.docs.isEmpty) {
        try {
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          // Obtener el userToken desde SharedPreferences
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          String? userToken = prefs.getString('userToken');

          // Guardar los datos del usuario en Firestore sin actualizar los datos que ya existían
          await FirebaseFirestore.instance.collection('users').doc(userToken).set({
            'name': name,
            'email': email,
            'password': password,  // TODO: No guardar la contraseña en texto plano
          }, SetOptions(merge: true));  // Se usa merge para no sobrescribir campos existentes

          // Se vuelve a la pantalla anterior
          Navigator.pop(context);
        } catch (e) {
          print('Error en el registro: $e');
        }
      } else {
        // Mensaje de error si el correo ya está registrado
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('El correo electrónico ya está registrado.'),
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
        title: Text('Registro'),
        backgroundColor: Colors.blue[400],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
              ElevatedButton(
                onPressed: register,
                child: Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
