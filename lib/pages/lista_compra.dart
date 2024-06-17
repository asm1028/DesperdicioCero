import 'package:flutter/material.dart';
import 'package:desperdiciocero/pages/productos_comprados.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ListaCompra extends StatefulWidget {
  ListaCompra({super.key});

  @override
  ListaCompraState createState() => ListaCompraState();
}

class ListaCompraState extends State<ListaCompra> {
  String _sortField = 'Nombre';
  String _sortOrder = 'Ascendente';
  String _filterText = '';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) async {
    ConnectivityResult result = results.last;
    if (result == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hay conexión a Internet. Los datos se sincronizarán automáticamente cuando se restablezca la conexión.'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<String?> getUserToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }

  Future<void> addProduct(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('userToken');

    if (_formKey.currentState!.validate() && userToken != null) {
      CollectionReference products = FirebaseFirestore.instance.collection('shopping_list');
      products
          .add({
            'name': name.trim(),
            'user_token': userToken,
            'added_day': FieldValue.serverTimestamp(),
          })
          .then((value) => print("Producto añadido"))
          .catchError((error) => print("Error al añadir producto: $error"));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Añadido "${name.trim()}"'),
          duration: Duration(seconds: 2),
        ),
      );
      _clearFields();
    }
  }

  void _clearFields() {
    _nameController.clear();
  }

  Future<void> _deleteItem(String itemId) async {
    await FirebaseFirestore.instance.collection('shopping_list').doc(itemId).delete();
  }

  Future<void> _moveToPurchased(String itemId, String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('userToken');

    if (userToken != null) {
      CollectionReference purchasedProducts = FirebaseFirestore.instance.collection('purchased_products');
      await purchasedProducts.add({
        'name': name,
        'user_token': userToken,
      });

      await FirebaseFirestore.instance.collection('shopping_list').doc(itemId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Producto "$name" movido a comprados'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _editItem(BuildContext context, String itemId, String currentName) async {
    TextEditingController nameController = TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(hintText: 'Nombre del producto'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('shopping_list').doc(itemId).update({
                  'name': nameController.text,
                  'added_day': FieldValue.serverTimestamp(),
                });
                Navigator.of(context).pop();
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showAddProductModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          title: Text('Añadir Nuevo Producto', textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Nombre del producto',
                        hintStyle: TextStyle(color: Colors.grey[550]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: Icon(FontAwesomeIcons.carrot, color: Color.fromARGB(255, 192, 70, 70)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el nombre del producto';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          addProduct(_nameController.text);
                          Navigator.pop(context);
                        }
                      },
                      icon: Icon(Icons.add),
                      label: Text('Añadir Producto'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _clearFields(),
                      icon: Icon(Icons.delete_sweep),
                      label: Text('Limpiar Campos'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista de la Compra',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.grey[400],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Buscar',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _filterText = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _sortField = _sortField == 'Nombre' ? 'Añadido el' : 'Nombre';
                        });
                      },
                      icon: Icon(Icons.sort),
                      label: Text(_sortField),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _sortOrder = _sortOrder == 'Ascendente' ? 'Descendente' : 'Ascendente';
                        });
                      },
                      icon: Icon(Icons.swap_vert),
                      label: Text(_sortOrder),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<String?>(
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
                      .collection('shopping_list')
                      .where('user_token', isEqualTo: userToken)
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Algo salió mal'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No hay productos en la lista de compra'));
                    }

                    final filteredDocs = snapshot.data!.docs.where((doc) {
                      return (doc['name'] as String).toLowerCase().contains(_filterText.toLowerCase());
                    }).toList();

                    filteredDocs.sort((a, b) {
                      int compare = _sortField == 'Nombre'
                          ? (a['name'] as String).compareTo(b['name'] as String)
                          : (a['added_day'] as Timestamp).compareTo(b['added_day'] as Timestamp);

                      return _sortOrder == 'Ascendente' ? compare : -compare;
                    });

                    return ListView(
                      children: filteredDocs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          elevation: 4,
                          margin: EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color.fromARGB(255, 192, 70, 70),
                              child: Icon(FontAwesomeIcons.carrot, color: Colors.white),
                            ),
                            title: Text(data['name']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _editItem(context, document.id, data['name']);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Eliminar Producto'),
                                          content: Text('¿Estás seguro de que quieres eliminar este producto?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _deleteItem(document.id);
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Eliminar'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.shopping_bag),
                                  onPressed: () {
                                    _moveToPurchased(document.id, data['name']);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            right: 5.0,
            bottom: 5.0,
            child: FloatingActionButton(
              onPressed: () {
                _showAddProductModal(context);
              },
              backgroundColor: Colors.grey[400],
              shape: CircleBorder(),
              child: Icon(Icons.add),
            ),
          ),
          Positioned(
            left: 30.0,
            bottom: 5.0,
            child: FloatingActionButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductosComprados()),
                );
              },
              backgroundColor: Colors.grey[400],
              shape: CircleBorder(),
              heroTag: "bagShoppingFAB", // Tag único para este botón, sino provoca un error de hero
              child: Icon(FontAwesomeIcons.bagShopping),
        ),
      ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
