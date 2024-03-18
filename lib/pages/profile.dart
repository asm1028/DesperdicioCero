import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  Profile({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Perfil',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[400],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Perfil del usuario\n\n'
              'Interfaz que pretende poder intercambiar\n' 
              'información con el frigorífico\n'
              'Para poder sincronizar la lista de\n' 
              'productos con la app\n\n',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              child: Text('Regresar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}