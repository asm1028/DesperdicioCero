import 'package:desperdiciocero/pages/home.dart';
import 'package:desperdiciocero/pages/lista_compra.dart';
import 'package:desperdiciocero/pages/lista_productos.dart';
import 'package:desperdiciocero/pages/recipes.dart';
import 'package:flutter/material.dart';

class PrimeraPagina extends StatefulWidget {
  PrimeraPagina({super.key});

  @override
  State<PrimeraPagina> createState() => _PrimeraPaginaState();
}

class _PrimeraPaginaState extends State<PrimeraPagina> {
  int _selectedIndex = 2;
  Color? _selectedItemColor = Colors.greenAccent[400];  // Color inicial para el ítem Home

  final List _pages = [
    ListaCompra(),
    RecipesPage(),
    Home(),
    ListaProductos()
  ];

  void _navigateBottomBar(int index){
    setState(() {
      _selectedIndex = index;
      switch(index) {
        case 0:
          _selectedItemColor = Colors.blue;  // Color para "Lista de la compra"
          break;
        case 1:
          _selectedItemColor = Colors.amber;   // Color para "Recetas"
          break;
        case 2:
          _selectedItemColor = Colors.greenAccent[400];  // Color para "Inicio"
          break;
        case 3:
          _selectedItemColor = Colors.purple;  // Color para "Productos"
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
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

          // Recetas
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_sharp),
            label: 'Recetas',
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
        selectedItemColor: _selectedItemColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}