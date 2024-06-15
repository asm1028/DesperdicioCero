import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:desperdicio_cero/pages/productos.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import statement

class ListaProductos extends StatelessWidget {
  ListaProductos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista de Productos',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.greenAccent[400],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Algo salió mal'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay productos'));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

              // Check if expiration_date is a Timestamp
              DateTime expirationDate;
              if (data['expiration_date'] is Timestamp) {
                expirationDate = (data['expiration_date'] as Timestamp).toDate();
              } else if (data['expiration_date'] is String) {
                expirationDate = DateTime.parse(data['expiration_date']);
              } else {
                return ListTile(
                  title: Text(data['name']),
                  subtitle: Text('Fecha de expiración no válida'),
                );
              }

              String expirationDateString = DateFormat('yyyy-MM-dd').format(expirationDate);

              return ListTile(
                title: Text(data['name']),
                subtitle: Text('Fecha de expiración: $expirationDateString'),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Productos()),
          );
        },
        backgroundColor: Colors.greenAccent[400],
        shape: CircleBorder(),
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
