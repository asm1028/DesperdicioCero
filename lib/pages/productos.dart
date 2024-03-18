import 'package:flutter/material.dart';

class Productos extends StatelessWidget {
  Productos({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Productos',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.greenAccent[400],
        leading: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text(
            'Lista Productos'
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/listaProductos',
              );
            },
        ),
      ),
    );
  } 
}
