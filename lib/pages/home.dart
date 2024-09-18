import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:desperdiciocero/pages/primera_pagina.dart';
import 'package:desperdiciocero/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Representa la página principal de la aplicación.
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

/// Representa el estado de la página principal de la aplicación.
///
/// Esta clase es responsable de gestionar el estado de la página de inicio.
/// Incluye métodos para obtener productos próximos a caducar y productos comprados,
/// cargar umbrales, liberar recursos, inicializar el estado y construir la interfaz de usuario.
class _HomeState extends State<Home> {
  DateTime? selectedDate;
  TextEditingController _filterController = TextEditingController();
  int oneDayThreshold = 1;
  int fiveDayThreshold = 5;

  /// Obtiene una lista de productos próximos a caducar.
  ///
  /// Este método recupera una lista de productos cuyas fechas de caducidad caen dentro de los próximos tres días.
  /// Requiere que se pase un token de usuario válido para realizar la consulta.
  ///
  /// Returns:
  ///  - Future<List<Map<String, dynamic>>>: Una lista de productos próximos a caducar.
  ///
  /// Si ocurre un error durante el proceso de recuperación, se devuelve una lista vacía.
  /// En caso de error, se muestra un SnackBar con un mensaje de error correspondiente.
  Future<List<Map<String, dynamic>>> _fetchExpiringProducts() async {
    String? userToken = await Utils().getUserToken();
    if (userToken == null) return [];

    // Cálculo de la fecha actual y la fecha dentro de 3 días
    DateTime now = DateTime.now();
    DateTime todayAtMidnight = DateTime(now.year, now.month, now.day);
    DateTime threeDaysLater = now.add(Duration(days: 50));
    Timestamp start = Timestamp.fromDate(todayAtMidnight);
    Timestamp end = Timestamp.fromDate(threeDaysLater);

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('user_token', isEqualTo: userToken)
          .where('expiration', isGreaterThanOrEqualTo: start)
          .where('expiration', isLessThanOrEqualTo: end)
          .get();

      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Algo salió mal. Por favor, inténtalo de nuevo. Error: ${e.toString()}'),
          duration: Duration(seconds: 2),
        ),
      );
      return [];
    }
  }

  /// Recupera una lista de productos comprados.
  ///
  /// Esta función realiza una consulta a la base de datos para obtener los productos comprados por el usuario actual.
  /// Utiliza el token de usuario obtenido a través de la clase `Utils` para filtrar los resultados.
  ///
  /// Retorna una lista de mapas, donde cada mapa representa un producto comprado y contiene información en formato clave-valor.
  /// Si no se encuentra ningún producto comprado o no se puede obtener el token de usuario, se retorna una lista vacía.
  Future<List<Map<String, dynamic>>> _fetchPurchasedProducts() async {
    String? userToken = await Utils().getUserToken();
    if (userToken == null) return [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('purchased_products')
        .where('user_token', isEqualTo: userToken)
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  /// Carga los umbrales desde las preferencias compartidas.
  ///
  /// Esta función asincrónica carga los umbrales de un día y de cinco días desde las preferencias compartidas.
  /// Si no se encuentran los umbrales en las preferencias, se utilizarán los valores predeterminados.
  /// Los umbrales cargados se asignarán a las variables [oneDayThreshold] y [fiveDayThreshold].
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// await loadThresholds();
  /// ```
  Future<void> loadThresholds() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      oneDayThreshold = prefs.getInt('oneDayThreshold') ?? oneDayThreshold;
      fiveDayThreshold = prefs.getInt('fiveDayThreshold') ?? fiveDayThreshold;
    });
  }

  /// Libera los recursos utilizados por la página de inicio.
  ///
  /// Este método se llama automáticamente cuando la página de inicio se elimina de la memoria.
  /// Se encarga de liberar los recursos utilizados por la página, como el controlador de filtro.
  /// Es importante llamar a este método para evitar fugas de memoria.
  ///
  /// Ejemplo de uso:
  ///
  /// ```dart
  /// @override
  /// void dispose() {
  ///   _filterController.dispose();
  ///   super.dispose();
  /// }
  /// ```
  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  /// Método que se llama al inicializar el estado del widget.
  /// Llama al método [loadThresholds] para cargar los umbrales.
  @override
  void initState() {
    super.initState();
    loadThresholds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DesperdicioCero',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.greenAccent[400],
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                FontAwesomeIcons.circleQuestion, // Icono de información
                color: const Color.fromARGB(255, 39, 37, 37),
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
                      'Esta aplicación te permite gestionar tus productos de manera eficiente. \n\nEn la parte superior del menú principal, encontrarás los productos próximos a caducar, mientras que en la inferior, los productos pendientes de añadir a tu lista, accesible desde el menú de navegación inferior derecho. \n\nAdemás, desde el menú lateral, accesible al pulsar las tres líneas a la izquierda del botón de información, podrás acceder al menú de usuario para registrarte o iniciar sesión, y al menú de configuración para ajustar los aspectos de la aplicación. \n\n¡Disfruta de la experiencia!',
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
          IconButton(
            icon: Icon(
              FontAwesomeIcons.rotateLeft,
              color: const Color.fromARGB(255, 39, 37, 37), // Cambia el color del icono a negro
            ),
            onPressed: () {
              // Función para recargar la página
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => PrimeraPagina(), // Recarga la página actual
                  transitionDuration: Duration(seconds: 0),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.greenAccent,
              ),
              child: Text(
                '\nBienvenido a DesperdicioCero!'
                '\n\nDesarrollado por: \n'
                'Alberto Santos Martínez',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('A J U S T E S'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/settings',
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('P E R F I L'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/profile',
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchExpiringProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Enhorabuena. No hay productos próximos a caducar.'));
                }
                var products = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                    elevation: 5,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Productos Próximos a Caducar',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              var product = products[index];
                              DateTime expirationDate = (product['expiration'] as Timestamp).toDate();
                              DateTime now = DateTime.now();
                              int daysToExpire = expirationDate.difference(now).inDays;

                              Color tileColor; // Variable para almacenar el color del tile
                              if (daysToExpire <= oneDayThreshold) {
                                // Si caduca hoy o mañana
                                tileColor = const Color.fromARGB(255, 235, 80, 80);
                              } else if (daysToExpire > oneDayThreshold && daysToExpire <= fiveDayThreshold) {
                                // Si caduca entre 2 y 5 días
                                tileColor = const Color.fromARGB(255, 255, 166, 63);
                              } else {
                                // Si caduca en 6 días o más
                                tileColor = const Color.fromARGB(255, 92, 204, 96);
                              }

                              return Container(
                                decoration: BoxDecoration(
                                  color: tileColor, // Cambia el color según la fecha de caducidad
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                        product['name'],
                                        style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Caduca: ${DateFormat('dd/MM/yyyy').format(expirationDate)}',
                                        style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                  Divider(height: 1), // Añade una fina línea entre cada item
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/productosComprados');
              },
              child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchPurchasedProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Has añadido toda tu compra a la lista de productos.'));
                }
                var purchasedProducts = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                    elevation: 5,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Productos que te faltan por añadir',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: purchasedProducts.length,
                            itemBuilder: (context, index) {
                              var item = purchasedProducts[index];
                                Color backgroundColor = index % 2 == 0 ? const Color.fromARGB(255, 11, 233, 126) : const Color.fromARGB(255, 223, 218, 218);  // Alternar colores

                              return Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),  // Bordes redondeados para el contenedor
                                    child: Container(
                                      color: backgroundColor,
                                      margin: EdgeInsets.only(bottom: 1.0),  // Margen para reducir espacio entre ítems
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),  // Reducir el padding vertical
                                        title: Text(
                                          item['name'],
                                          style: TextStyle(
                                          color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Divider(height: 1),  // Divisor entre ítems
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
