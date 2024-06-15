import 'package:desperdicio_cero/pages/home.dart';
import 'package:desperdicio_cero/pages/lista_compra.dart';
import 'package:desperdicio_cero/pages/lista_productos.dart';
import 'package:flutter/material.dart';

class PrimeraPagina extends StatefulWidget {
  PrimeraPagina({super.key});

  @override
  State<PrimeraPagina> createState() => _PrimeraPaginaState();
}

class _PrimeraPaginaState extends State<PrimeraPagina> {
  int _selectedIndex = 1;

  final List _pages = [
    ListaCompra(),
    Home(),
    ListaProductos()
  ];

  void _navigateBottomBar(int index){
    setState(() {
      _selectedIndex = index;  
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'DesperdicioCero',
      //     style: TextStyle(
      //       color: Colors.white,
      //     ),
      //   ),
      //   backgroundColor: Colors.greenAccent[400],
      // ),
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        items: <BottomNavigationBarItem>[
          // Lista de la compra
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Lista de la compra',
          ),

          // Home
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),

          // Productos
          BottomNavigationBarItem(
            // icon: Icon(Icons.fastfood),
            // icon: Icon(Icons.dashboard),
            icon: Icon(Icons.local_dining),
            label: 'Productos',
          ),
        ],
        selectedItemColor: Colors.greenAccent[400],
      ),
    );
  }
}