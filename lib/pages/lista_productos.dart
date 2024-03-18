import 'package:flutter/material.dart';

class ListaProductos extends StatelessWidget {
  ListaProductos({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista de Productos',
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
            'Regresar'
            ),
            onPressed: () {
              Navigator.pop(context);
            },
        ),
      ),
    );
  }

}