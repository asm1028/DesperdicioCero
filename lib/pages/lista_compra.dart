import 'package:desperdiciocero/pages/productos_compra.dart';
import 'package:desperdiciocero/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:desperdiciocero/pages/productos_comprados.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desperdiciocero/assets/products_data.dart';

class ListaCompra extends StatefulWidget {
  ListaCompra({super.key});

  @override
  ListaCompraState createState() => ListaCompraState();
}

class ListaCompraState extends State<ListaCompra> {
  String _sortField = 'Nombre';
  String _sortOrder = 'Ascendente';
  String _filterText = '';

  final Connectivity _connectivity = Connectivity();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
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
    ConnectivityResult result = results.first;
    if (result == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hay conexión a Internet. Los datos se sincronizarán automáticamente cuando se restablezca la conexión.'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _deleteItem(String itemId) async {
    try {
      FirebaseFirestore.instance.collection('shopping_list').doc(itemId).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar el producto'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _moveToPurchased(String itemId, String name) async {
    final userToken = await Utils().getUserToken();

    try  {
      if (userToken != null) {
        CollectionReference purchasedProducts = FirebaseFirestore.instance.collection('purchased_products');
        purchasedProducts.add({
          'name': name,
          'user_token': userToken,
        });

        FirebaseFirestore.instance.collection('shopping_list').doc(itemId).delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto "$name" movido a comprados'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al mover el producto a comprados'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _editItem(BuildContext context, String productId, String currentName) async {
    TextEditingController nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(  // Utiliza StatefulBuilder para manejar el estado local
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Editar Producto'),
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(); // Cierra el diálogo primero
                    _showLoadingDialog(); // Muestra el diálogo de carga

                    try {
                      FirebaseFirestore.instance.collection('shopping_list').doc(productId).update({
                        'name': nameController.text,
                        'added_day': FieldValue.serverTimestamp(),
                      });

                      Navigator.of(context, rootNavigator: true).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Producto editado correctamente.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      Navigator.of(context, rootNavigator: true).pop();
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
            );
          }
        );
      },
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: scaffoldKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Procesando..."),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Cerrar el teclado al tocar fuera de un campo de texto
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      key: scaffoldKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Lista de la Compra',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
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
                        'En esta interfaz tienes tu propia lista de la compra. Puedes añadir productos, editarlos, eliminarlos y marcarlos como comprados al dar click en la bolsa. ¡Haz clic en el botón "+" para añadir un producto!',
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
                future: Utils().getUserToken(),
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
                        children: [
                          ...filteredDocs.map((DocumentSnapshot document) {
                            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                            String productName = data['name'];
                            String category = productos[productName] ?? 'Cesta';
                            String iconPath = 'lib/assets/images/$category.png';

                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              elevation: 4,
                              margin: EdgeInsets.all(8.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Color.fromARGB(255, 192, 70, 70),
                                  child: CircleAvatar(
                                    radius: 17,
                                    backgroundColor: Colors.white,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(iconPath),
                                          fit: BoxFit.contain, // Para que la imagen no se corte
                                        ),
                                      ),
                                    ),
                                  ),
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
                          }),
                          SizedBox(height: 80),
                        ],
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
              right: 0.0,
              bottom: 0.0,
              child: FloatingActionButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductosCompra()),
                  );
                },
                backgroundColor: Colors.blue[400],
                shape: CircleBorder(),
                child: Icon(Icons.add),
              ),
            ),
            Positioned(
              left: 30.0,
              bottom: 0.0,
              child: FloatingActionButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductosComprados()),
                  );
                },
                backgroundColor: Colors.blue[400],
                shape: CircleBorder(),
                heroTag: "bagShoppingFAB",
                child: Icon(FontAwesomeIcons.bagShopping),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
