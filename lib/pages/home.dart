import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:desperdiciocero/pages/primera_pagina.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime? selectedDate;
  TextEditingController _filterController = TextEditingController();
  int oneDayThreshold = 1;
  int fiveDayThreshold = 5;

  Future<String?> _getUserToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }

  Future<List<Map<String, dynamic>>> _fetchExpiringProducts() async {
    String? userToken = await _getUserToken();
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

  Future<List<Map<String, dynamic>>> _fetchPurchasedProducts() async {
    String? userToken = await _getUserToken();
    if (userToken == null) return [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('purchased_products')
        .where('user_token', isEqualTo: userToken)
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<void> loadThresholds() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      oneDayThreshold = prefs.getInt('oneDayThreshold') ?? oneDayThreshold;
      fiveDayThreshold = prefs.getInt('fiveDayThreshold') ?? fiveDayThreshold;
    });
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

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
        actions: <Widget>[
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
                                    ),
                                    ),
                                    subtitle: Text(
                                    'Caduca: ${DateFormat('dd/MM/yyyy').format(expirationDate)}',
                                    style: TextStyle(
                                      color: Colors.black54,
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
                                        title: Text(item['name']),
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
