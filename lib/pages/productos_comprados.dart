import 'package:desperdiciocero/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class ProductosComprados extends StatelessWidget {
  ProductosComprados({super.key});

  void _editProduct(BuildContext context, String productId, String currentName) async {
    TextEditingController nameController = TextEditingController(text: currentName);
    DateTime selectedDate = DateTime.now(); // Fecha por defecto
    int additionalDays = 0; // Variable para el selector de días adicionales

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return WillPopScope(
              onWillPop: () async {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (BuildContext context) => ProductosComprados()),
                );
                return true;
              },
              child: AlertDialog(
                title: Text('Editar Producto'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(hintText: 'Nombre del producto'),
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        Text('Fecha de caducidad: '),
                        TextButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2050),
                            );
                            if (picked != null && picked != selectedDate) {
                              setState(() {
                                selectedDate = picked;
                                additionalDays = 0; // Reset additional days if date is picked
                              });
                            }
                          },
                          child: Text(DateFormat('dd/MM/yyyy').format(selectedDate.add(Duration(days: additionalDays))))),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Text('Días adicionales:'),
                    SizedBox(
                      height: 100,
                      child: CupertinoPicker(
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int value) {
                          setState(() {
                            additionalDays = value;
                          });
                        },
                        children: List<Widget>.generate(31, (int index) {
                          return Center(
                            child: Text(index.toString()),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (BuildContext context) => ProductosComprados()),
                      );
                    },
                    child: Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () async {
                      DateTime finalExpiryDate = selectedDate.add(Duration(days: additionalDays));
                      String userToken = (await Utils().getUserToken())!;

                      try {
                        // Agregar producto a la base de datos "products"
                        FirebaseFirestore.instance.collection('products').add({
                          'name': nameController.text,
                          'expiration': Timestamp.fromDate(finalExpiryDate),
                          'user_token': userToken,
                        });

                        // Eliminar producto de la base de datos "purchased_products"
                        FirebaseFirestore.instance.collection('purchased_products').doc(productId).delete();

                        Navigator.of(context).pop();
                      } catch (e) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Algo salió mal. Por favor, inténtalo de nuevo.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Text('Guardar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _deleteProduct(BuildContext context, String productId) async {
    try {
      FirebaseFirestore.instance.collection('purchased_products').doc(productId).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Algo salió mal. Por favor, inténtalo de nuevo.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bolsa de la Compra', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[400],
        actions: <Widget>[
            IconButton(
              icon: Icon(
                FontAwesomeIcons.circleQuestion, // Icono de información
                color: Colors.white,
              ),
              onPressed: () {
                // Función para mostrar un diálogo con información
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                      return AlertDialog(
                      title: Text(
                        'Información',
                        style: TextStyle(fontSize: 22),
                      ),
                      content: Text(
                        'Aquí puedes encontrar todos los productos que has añadido a tu lista de la compra. Puedes añadir nuevos productos pulsando el botón "+" y eliminarlos deslizando hacia la izquierda. También puedes editar un producto pulsando sobre el producto o deslizando hacia la derecha.',
                        style: TextStyle(fontSize: 16),
                      ),
                      actions: <Widget>[
                        TextButton(
                        child: Text(
                          'Cerrar',
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
      ),
      body: FutureBuilder<String?>(
        future: Utils().getUserToken(),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Algo salió mal'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No se pudo obtener el token del usuario'));
          }

          final String userToken = snapshot.data!;
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('purchased_products')
                .where('user_token', isEqualTo: userToken)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Algo salió mal'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No hay productos comprados'));
              }

              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  return Dismissible(
                    key: Key(document.id),
                    background: Container(
                      color: Colors.green,
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                    onDismissed: (direction) {
                      if (direction == DismissDirection.startToEnd) {
                        // Si se desliza hacia la derecha, abrir el editor
                        _editProduct(context, document.id, data['name']);
                      } else {
                        // Si se desliza hacia la izquierda, intentar eliminar
                        _deleteProduct(context, document.id);
                      }
                    },
                    child: Card(
                      elevation: 4,
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(data['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () => _editProduct(context, document.id, data['name']),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
