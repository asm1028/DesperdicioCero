import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:desperdicio_cero/pages/productos.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListaProductos extends StatelessWidget {
  ListaProductos({super.key});

  Future<String?> getUserToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }

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
      body: FutureBuilder<String?>(
        future: getUserToken(),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Algo salió mal'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No se pudo obtener el token del usuario'));
          }

          final String userToken = snapshot.data!;
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where('user_token', isEqualTo: userToken)
                .snapshots(),
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
                  if (data['expiration'] is Timestamp) {
                    expirationDate = (data['expiration'] as Timestamp).toDate();
                  } else if (data['expiration'] is String) {
                    expirationDate = DateTime.parse(data['expiration']);
                  } else {
                    return ListTile(
                      title: Text(data['name']),
                      subtitle: Text('Fecha de expiración no válida'),
                    );
                  }

                  String expirationDateString = DateFormat('dd/MM/yyyy').format(expirationDate);

                  return ListTile(
                    title: Text(data['name']),
                    subtitle: Text('Fecha de expiración: $expirationDateString'),
                  );
                }).toList(),
              );
            },
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
