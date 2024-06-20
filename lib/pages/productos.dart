import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desperdiciocero/assets/products_data.dart';

class Productos extends StatefulWidget {
  Productos({super.key});

  @override
  ProductosState createState() => ProductosState();
}

class ProductosState extends State<Productos> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _dateSelected = true;
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

  void _updateConnectionStatus(List<ConnectivityResult> result) async {
    if (result == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hay conexión a Internet. Los datos se sincronizarán automáticamente cuando se restablezca la conexión.'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> addProduct(String name, DateTime expirationDate) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('userToken');

    if (_formKey.currentState!.validate() && _dateSelected && userToken != null) {
      CollectionReference products = FirebaseFirestore.instance.collection('products');
      await products.add({
        'name': name,
        'expiration': expirationDate, // Fecha de caducidad
        'user_token': userToken, // Token del usuario
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Añadido "$name" con fecha de expiración ${DateFormat('dd/MM/yyyy').format(expirationDate)}'),
          duration: Duration(seconds: 2),
        ),
      );
      _clearFields(true, false);
    }
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateSelected = true;
      });
    }
  }

  void _clearFields(bool clearDate, bool showMessage) {
    _nameController.clear();
    if (clearDate) {
      setState(() {
        _selectedDate = DateTime.now();
        _dateSelected = true;
      });
    }
    if (showMessage) {
      _showClearFieldsMessage();
    }
  }

  void _showClearFieldsMessage() {
    // Elimina el Snackbar actual si está mostrándose
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Campos limpiados'),
        duration: Duration(seconds: 2),
      ),
    );
  }

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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Añadir Nuevo Producto',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        return productos.keys.where((String option) {
                          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (String selection) {
                        _nameController.text = selection;
                        _nameController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _nameController.text.length),
                        );
                      },
                      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                        _nameController.addListener(() {
                          setState(() {});
                        });
                        return TextFormField(
                          controller: _nameController,
                          focusNode: focusNode,
                          onEditingComplete: onEditingComplete,
                          decoration: InputDecoration(
                            hintText: 'Nombre del producto',
                            hintStyle: TextStyle(color: Colors.grey[550]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            prefixIcon: Icon(FontAwesomeIcons.carrot, color: Color.fromARGB(255, 192, 70, 70)),
                            suffixIcon: Container(
                              width: 48, // Ancho fijo para el contenedor del contador
                              alignment: Alignment.center, // Centra el texto dentro del contenedor
                              child: Text(
                                '${40 - _nameController.text.length}', // Muestra los caracteres restantes de 40
                                style: TextStyle(color: Colors.grey), // Estilo del texto en gris
                              ),
                            ),
                            counterText: '', // Oculta el contador predeterminado
                          ),
                          maxLength: 40,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese el nombre del producto';
                            }
                            return null;
                          },
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.82,
                              height: MediaQuery.of(context).size.height * 0.3, // Ajusta la altura para mejor visualización
                              child: ListView.builder(
                                padding: EdgeInsets.all(0.0),
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final String option = options.elementAt(index);
                                  return ListTile(
                                    title: Text(option),
                                    onTap: () {
                                      onSelected(option);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: Icon(Icons.calendar_today),
                      label: Text('Seleccionar fecha'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Fecha de expiración: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 50),
                    ElevatedButton.icon(
                      onPressed: () => addProduct(_nameController.text, _selectedDate),
                      icon: Icon(Icons.add),
                      label: Text('Añadir Producto'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _clearFields(true, true),
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
        ),
      ),
    );
  }
}
