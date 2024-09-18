import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:desperdiciocero/assets/products_data.dart';
import 'package:desperdiciocero/utils/autocomplete_products.dart';

/// Esta clase representa la página de añadir productos de forma manual.
class Productos extends StatefulWidget {
  Productos({super.key});

  @override
  ProductosState createState() => ProductosState();
}

/// Esta clase representa el estado de la página de añadir productos de forma manual.
class ProductosState extends State<Productos> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  /// Inicializa el estado de la página de productos.
  @override
  void initState() {
    super.initState();
  }


  /// Añade un producto a la base de datos.
  ///
  /// Este método toma el nombre del producto y la fecha de caducidad como parámetros.
  /// Primero, obtiene el token de usuario almacenado en las preferencias compartidas.
  /// Luego, valida el formulario y el token de usuario.
  /// Si el formulario es válido y se ha proporcionado un token de usuario, se agrega el producto a la colección 'products' en Firestore.
  /// El nombre del producto se recorta y se guarda junto con la fecha de caducidad y el token de usuario.
  /// A continuación, se muestra una notificación emergente con el nombre del producto y la fecha de caducidad.
  /// Por último, se limpian los campos del formulario.
  /// Si ocurre algún error, se muestra una notificación emergente indicando que algo salió mal.
  ///
  /// Parámetros:
  ///   - [name]: El nombre del producto.
  ///   - [expirationDate]: La fecha de caducidad del producto.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// addProduct('Manzanas', DateTime.now());
  /// ```
  void addProduct(String name, DateTime expirationDate) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('userToken');

    try {
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Algo salió mal. Por favor, inténtalo de nuevo.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Muestra un diálogo de selección de fecha y actualiza la fecha seleccionada.
  ///
  /// Este método muestra un diálogo de selección de fecha utilizando el [showDatePicker]
  /// y actualiza la fecha seleccionada en el estado del widget.
  ///
  /// - `context`: El contexto de la aplicación.
  ///
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

  /// Limpia los campos del formulario.
  ///
  /// Esta función se encarga de limpiar los campos del formulario en la página de productos.
  /// Limpia el campo de nombre (_nameController) y establece la fecha seleccionada (_selectedDate)
  /// como la fecha actual.
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
          backgroundColor: Colors.purple[400],
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
                        'Aquí puedes añadir productos manualmente. Ingresa el nombre del producto y selecciona la fecha de expiración. ',
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
