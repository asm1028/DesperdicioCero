import 'package:desperdicio_cero/models/productos.dart';
import 'package:flutter/material.dart';

class Productos extends StatelessWidget {
  Productos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      /*
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getProductos(), // Cambia la llamada al método
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // Construye la lista de productos utilizando los datos obtenidos de la base de datos
            // Por ejemplo:
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var producto = snapshot.data![index];
                return ListTile(
                  title: Text(producto['nombre_producto']),
                  subtitle: Text(producto['fecha_caducidad']),
                  // Agrega más detalles según sea necesario
                );
              },
            );
          }
        },
      ),*/
    );
  }

  // Future<List<Map<String, dynamic>>> _getProductos() async {
  //   try {
  //     final db = await DatabaseHelper().database; // Cambia aquí
  //     return await db.query('Productos');
  //   } catch (e) {
  //     print("Error al obtener los productos: $e");
  //     return [];
  //   }
  // }
}