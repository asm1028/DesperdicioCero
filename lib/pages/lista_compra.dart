import 'package:flutter/material.dart';

class ListaCompra extends StatelessWidget {
  ListaCompra({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista de la compra',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.grey[400],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lista de la compra\n\n'
              'Interfaz para añadir cosas\n' 
              'al carrito de la compra\n\n\n',
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