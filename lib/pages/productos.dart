import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:desperdiciocero/assets/products_data.dart';
import 'package:desperdiciocero/utils/autocomplete_products.dart';

class Productos extends StatefulWidget {
  Productos({super.key});

  @override
  ProductosState createState() => ProductosState();
}

class ProductosState extends State<Productos> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  void addProduct(String name, DateTime expirationDate) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('userToken');

    if (_formKey.currentState!.validate() && userToken != null) {
      CollectionReference products = FirebaseFirestore.instance.collection('products');
      products.add({
        'name': name.trim(),
        'expiration': expirationDate,
        'user_token': userToken,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Producto añadido: "${name.trim()}" con fecha de expiración ${DateFormat('dd/MM/yyyy').format(expirationDate)}'),
            duration: Duration(seconds: 2),
        ),
      );
      _clearFields();
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _clearFields() {
    _nameController.clear();
    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Añadir Productos', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.greenAccent[400],
        ),
        body: SingleChildScrollView(
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
                  children: [
                    Text('Añadir Nuevo Producto', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    CustomAutocomplete(
                      controller: _nameController,
                      suggestions: productos.keys.toList(),
                      onChanged: (value) {
                        setState(() {});
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el nombre del producto';
                        } else if (value.length > 40) {
                          return 'El nombre del producto no puede exceder los 40 caracteres';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: Icon(Icons.calendar_today),
                      label: Text('Seleccionar fecha'),
                    ),
                    SizedBox(height: 16),
                    Text('Fecha de expiración: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 50),
                    ElevatedButton.icon(
                      onPressed: () => addProduct(_nameController.text, _selectedDate),
                      icon: Icon(Icons.add),
                      label: Text('Añadir Producto'),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _clearFields,
                      icon: Icon(Icons.delete_sweep),
                      label: Text('Limpiar Campos'),
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
