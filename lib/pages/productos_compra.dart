import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:desperdiciocero/assets/products_data.dart';
import 'package:desperdiciocero/utils/autocomplete_products.dart';

/// Esta clase representa la página de añadir productos de forma manual.
class ProductosCompra extends StatefulWidget {
  ProductosCompra({super.key});

  @override
  ProductosCompraState createState() => ProductosCompraState();
}

class ProductosCompraState extends State<ProductosCompra> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  /// Inicializa el estado de la página de productos.
  @override
  void initState() {
    super.initState();
  }

  /// Agrega un producto a la base de datos.
  ///
  /// Esta función recibe el nombre del producto y la fecha de expiración como parámetros.
  /// Verifica si el formulario es válido y si el token de usuario no es nulo.
  /// Luego, agrega el producto a la colección 'products' en la base de datos de Firebase.
  /// Muestra un mensaje emergente con el nombre del producto y su fecha de expiración.
  /// Finalmente, limpia los campos del formulario.
  void addProduct(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('userToken');

    try{
      if (_formKey.currentState!.validate() && userToken != null) {
        CollectionReference products = FirebaseFirestore.instance.collection('shopping_list');
        products.add({
          'name': name.trim(),
          'user_token': userToken,
          'added_day': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto añadido: "${name.trim()}" al carro de la compra'),
            duration: Duration(seconds: 2),
          ),
        );
        _clearFields();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Algo salió mal. Por favor, inténtalo de nuevo.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _clearFields() {
    _nameController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Añadir al Carro', style: TextStyle(color: Colors.white)),
          backgroundColor:  Colors.blue[400],
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
                    Text('Añadir Producto al Carro', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                      onPressed: () => addProduct(_nameController.text),
                      icon: Icon(Icons.add),
                      label: Text('Añadir Producto'),
                    ),
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
