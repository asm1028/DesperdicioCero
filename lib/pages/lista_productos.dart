import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:desperdiciocero/pages/productos.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListaProductos extends StatefulWidget {
  ListaProductos({super.key});

  @override
  _ListaProductosState createState() => _ListaProductosState();
}

class _ListaProductosState extends State<ListaProductos> {
  String _sortOrder = 'expiration'; // Default sort order
  String _filterText = '';
  DateTime? _selectedDate;

  Future<String?> getUserToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }

  Future<void> _deleteProduct(String productId) async {
    await FirebaseFirestore.instance.collection('products').doc(productId).delete();
  }

  Future<void> _editProduct(BuildContext context, String productId, String currentName, DateTime currentExpirationDate) async {
    TextEditingController _nameController = TextEditingController(text: currentName);
    DateTime _selectedDate = currentExpirationDate;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(hintText: 'Nombre del producto'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2050),
                  );
                  if (picked != null) {
                    _selectedDate = picked;
                  }
                },
                child: Text('Seleccionar caducidad'),
              ),
              SizedBox(height: 16),
              Text('Caducidad: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
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
                await FirebaseFirestore.instance.collection('products').doc(productId).update({
                  'name': _nameController.text,
                  'expiration': _selectedDate,
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
                    Expanded(
                      child: TextField(
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
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: Text(_selectedDate == null ? 'Fecha' : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Ordenar por:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                DropdownButton<String>(
                  value: _sortOrder,
                  icon: Icon(Icons.sort),
                  iconSize: 24,
                  onChanged: (String? newValue) {
                    setState(() {
                      _sortOrder = newValue!;
                    });
                  },
                  items: <String>['expiration', 'name']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          value == 'expiration' ? 'Fecha de caducidad' : 'Nombre',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  }).toList(),
                ),
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

                    if (_selectedDate != null) {
                      docs = docs.where((doc) {
                        DateTime expirationDate = doc['expiration'] is Timestamp
                            ? (doc['expiration'] as Timestamp).toDate()
                            : DateTime.parse(doc['expiration']);
                        return expirationDate == _selectedDate;
                      }).toList();
                    }

                    if (_sortOrder == 'expiration') {
                      docs.sort((a, b) {
                        DateTime expirationA = a['expiration'] is Timestamp
                            ? (a['expiration'] as Timestamp).toDate()
                            : DateTime.parse(a['expiration']);
                        DateTime expirationB = b['expiration'] is Timestamp
                            ? (b['expiration'] as Timestamp).toDate()
                            : DateTime.parse(b['expiration']);
                        return expirationA.compareTo(expirationB);
                      });
                    } else if (_sortOrder == 'name') {
                      docs.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
                    }

                    return GridView.builder(
                      padding: EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 1,
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
                          padding: EdgeInsets.all(16),
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
                                style: TextStyle(fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _editProduct(context, productId, data['name'], expirationDate),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteProduct(productId),
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
        backgroundColor: Colors.greenAccent[400],
        shape: CircleBorder(),
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
