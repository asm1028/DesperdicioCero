import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:desperdiciocero/pages/productos.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _sortField = 'Fecha de caducidad';
  String _sortOrder = 'Ascendente';
  String _filterText = '';
  DateTime? selectedDate;
  TextEditingController _filterController = TextEditingController();

  Future<String?> _getUserToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }

  Future<List<Map<String, dynamic>>> _fetchExpiringProducts() async {
    String? userToken = await _getUserToken();
    if (userToken == null) return [];

    DateTime today = DateTime.now();
    DateTime threeDaysLater = today.add(Duration(days: 3));

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('user_token', isEqualTo: userToken)
        .where('expiration', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
        .where('expiration', isLessThanOrEqualTo: Timestamp.fromDate(threeDaysLater))
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
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

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
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
                  fontSize: 20,
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
                  return Center(child: Text('No hay productos próximos a caducar.'));
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
                              return ListTile(
                                title: Text(product['name']),
                                subtitle: Text('Caduca: ${DateFormat('dd/MM/yyyy').format(expirationDate)}'),
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
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchPurchasedProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay productos en la bolsa de la compra.'));
                }
                var purchasedProducts = snapshot.data!;
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
                            'Productos en la Bolsa de la Compra',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: purchasedProducts.length,
                            itemBuilder: (context, index) {
                              var item = purchasedProducts[index];
                              return ListTile(
                                title: Text(item['name']),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/recognizeExpirationDate');
        },
        backgroundColor: Colors.greenAccent[400],
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/images/Camara.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
