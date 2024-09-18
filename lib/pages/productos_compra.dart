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

/// Esta clase representa el estado de la página de añadir productos de forma manual.
class ProductosCompraState extends State<ProductosCompra> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  /// Inicializa el estado de la página de productos.
  @override
  void initState() {
    super.initState();
  }

  /// Añade un producto al carrito de la compra.
  ///
  /// Este método toma el nombre del producto como parámetro y lo agrega al carrito de la compra en la base de datos.
  /// Para poder agregar el producto, se requiere que el formulario sea válido y que el token de usuario no sea nulo.
  /// Si se cumple esta condición, se crea una referencia a la colección 'shopping_list' en la base de datos de Firestore
  /// y se agrega un nuevo documento con los siguientes campos:
  ///   - 'name': el nombre del producto (sin espacios en blanco al principio o al final).
  ///   - 'user_token': el token de usuario obtenido de las preferencias compartidas.
  ///   - 'added_day': la marca de tiempo del servidor en el momento de agregar el producto.
  ///
  /// Después de agregar el producto, se muestra una notificación emergente con el mensaje "Producto añadido: [nombre del producto] al carro de la compra".
  /// Los campos del formulario se borran después de agregar el producto.
  /// Si ocurre algún error durante el proceso, se muestra una notificación emergente con el mensaje "Algo salió mal. Por favor, inténtalo de nuevo."
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
