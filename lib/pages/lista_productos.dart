import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:desperdiciocero/pages/productos.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListaProductos extends StatefulWidget {
  ListaProductos({super.key});

  @override
  ListaProductosState createState() => ListaProductosState();
}

class ListaProductosState extends State<ListaProductos> {
  // Valores inciales de los filtros y orden
  String _sortField = 'Fecha de caducidad';
  String _sortOrder = 'Ascendente';

  String _filterText = '';
  DateTime? selectedDate;
  TextEditingController _filterController = TextEditingController();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Función para obtener el token del usuario
  Future<String?> getUserToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }

  // Función para eliminar un producto
  void _deleteProduct(BuildContext context, String productId) async {
    final productRef = FirebaseFirestore.instance.collection('products').doc(productId);
    final userToken = await getUserToken();

    if (userToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo obtener la información del usuario.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Eliminar Producto'),
          content: Text('¿Estás seguro de que quieres eliminar este producto?'),
          actions: [
            // Botón para cancelar la operación
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancelar'),
            ),
            // Botón para mover el producto a la lista de la compra
            TextButton(
              onPressed: () async {
                // Cierra el diálogo antes de la operación asincrónica
                Navigator.of(dialogContext).pop();
                _showLoadingDialog();

                try {
                  DocumentSnapshot productDoc = await productRef.get();
                  if (!productDoc.exists) {
                    Navigator.of(context, rootNavigator: true).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('El producto no existe.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  final productData = productDoc.data() as Map<String, dynamic>;
                  FirebaseFirestore.instance.collection('shopping_list').add({
                    'name': productData['name'],
                    'added_day': DateTime.now(),
                    'user_token': userToken,
                  });
                  productRef.delete();

                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Producto movido a la lista de la compra y eliminado.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Algo salió mal: ${e.toString()}'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Mover a Lista de Compra'),
            ),
            // Botón para eliminar el producto
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                _showLoadingDialog();

                try {
                  productRef.delete();
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Producto eliminado.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar el producto: ${e.toString()}'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editProduct(BuildContext context, String productId, String currentName, DateTime currentExpirationDate) async {
    TextEditingController nameController = TextEditingController(text: currentName);
    DateTime selectedDate = currentExpirationDate;

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
                  SizedBox(height: 16),
                  // Selector de fecha
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2050),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Text('Seleccionar caducidad'),
                  ),
                  SizedBox(height: 16),
                  Text('Caducidad: ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
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
                      FirebaseFirestore.instance.collection('products').doc(productId).update({
                        'name': nameController.text,
                        'expiration': selectedDate,
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
                          content: Text('Algo salió mal. Por favor, inténtalo de nuevo. Error: ${e.toString()}'),
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

  // Función que muestra un diálogo de carga
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
  void dispose() {
    _filterController.dispose();
    super.dispose();
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
            'Lista de Productos',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.purple[400],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtrar por:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _filterText = ''; // Limpia el filtro de texto
                            _filterController.clear(); // Limpia el texto del TextField
                            selectedDate = null; // Limpia el filtro de fecha
                          });
                        },
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _filterController,
                          decoration: InputDecoration(
                            hintText: 'Nombre',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _filterText = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2050),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: Text(selectedDate == null ? 'Fecha' : DateFormat('dd/MM/yyyy').format(selectedDate!)),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Ordenar por:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            if (_sortField == 'Fecha de caducidad') {
                              _sortField = 'Nombre';
                            } else {
                              _sortField = 'Fecha de caducidad';
                            }
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

                      List<DocumentSnapshot> docs = snapshot.data!.docs;

                      if (_filterText.isNotEmpty) {
                        docs = docs.where((doc) {
                          return (doc['name'] as String)
                              .toLowerCase()
                              .contains(_filterText.toLowerCase());
                        }).toList();
                      }

                      if (selectedDate != null) {
                        docs = docs.where((doc) {
                          DateTime expirationDate = doc['expiration'] is Timestamp
                              ? (doc['expiration'] as Timestamp).toDate()
                              : DateTime.parse(doc['expiration']);
                          return expirationDate == selectedDate;
                        }).toList();
                      }

                      if (_sortField == 'Fecha de caducidad') {
                        docs.sort((a, b) {
                          DateTime expirationA = a['expiration'] is Timestamp
                              ? (a['expiration'] as Timestamp).toDate()
                              : DateTime.parse(a['expiration']);
                          DateTime expirationB = b['expiration'] is Timestamp
                              ? (b['expiration'] as Timestamp).toDate()
                              : DateTime.parse(b['expiration']);
                          return _sortOrder == 'Ascendente'
                              ? expirationA.compareTo(expirationB)
                              : expirationB.compareTo(expirationA);
                        });
                      } else if (_sortField == 'Nombre') {
                        docs.sort((a, b) {
                          int comparison = (a['name'] as String).compareTo(b['name'] as String);
                          return _sortOrder == 'Ascendente' ? comparison : -comparison;
                        });
                      }

                      return GridView.builder(
                        padding: EdgeInsets.all(8.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 1.15,
                        ),
                        itemCount: docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot document = docs[index];
                          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                          String productId = document.id;

                          DateTime expirationDate;
                          if (data['expiration'] is Timestamp) {
                            expirationDate = (data['expiration'] as Timestamp).toDate();
                          } else if (data['expiration'] is String) {
                            expirationDate = DateTime.parse(data['expiration']);
                          } else {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text('Fecha de caducidad no válida'),
                              ),
                            );
                          }

                          String expirationDateString = DateFormat('dd/MM/yyyy').format(expirationDate);

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(15),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  data['name'],
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Caducidad: $expirationDateString',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: expirationDate.isBefore(DateTime.now()) ? Colors.red : null,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: const Color.fromARGB(255, 60, 224, 66)),
                                      onPressed: () => _editProduct(context, productId, data['name'], expirationDate),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteProduct(context, productId),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Productos()),
            );
          },
          backgroundColor: Colors.purple[400],
          shape: CircleBorder(),
          child: Icon(Icons.add, color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            ),
    );
  }
}
