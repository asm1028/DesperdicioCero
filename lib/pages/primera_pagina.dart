import 'package:desperdiciocero/pages/home.dart';
import 'package:desperdiciocero/pages/lista_compra.dart';
import 'package:desperdiciocero/pages/lista_productos.dart';
import 'package:desperdiciocero/pages/recipes.dart';
import 'package:flutter/material.dart';

/// Clase que representa la primera página de la aplicación.
///
/// Esta clase es un StatefulWidget que muestra la primera página de la aplicación.
/// Se utiliza para inicializar y mantener el estado de la página.
class PrimeraPagina extends StatefulWidget {
  PrimeraPagina({super.key});

  @override
  State<PrimeraPagina> createState() => _PrimeraPaginaState();
}

/// Clase que representa el estado de la primera página de la aplicación.
class _PrimeraPaginaState extends State<PrimeraPagina> {
  int _selectedIndex = 2;
  Color? _selectedItemColor = Colors.greenAccent[400];  // Color inicial para el ítem Home

  final List _pages = [
    ListaCompra(),
    RecipesPage(),
    Home(),
    ListaProductos()
  ];

  /// Navega a la opción seleccionada en la barra inferior y actualiza el color del ítem seleccionado.
  ///
  /// El parámetro [index] indica el índice de la opción seleccionada.
  /// Los valores posibles para [index] son:
  ///   - 0: "Lista de la compra"
  ///   - 1: "Recetas"
  ///   - 2: "Inicio"
  ///   - 3: "Productos"
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// _navigateBottomBar(2); // Navega a la opción "Inicio" y actualiza el color del ítem seleccionado.
  /// ```
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
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            height: 1,
            color: Theme.of(context).brightness == Brightness.dark
              ? const Color.fromARGB(255, 42, 36, 36) // Modo oscuro
              : Colors.grey.withOpacity(0.5), // Modo claro
            ),
          BottomNavigationBar(
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
                icon: Icon(Icons.local_dining),
                label: 'Productos',
              ),
            ],
            selectedItemColor: _selectedItemColor,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: TextStyle(fontSize: 16), // Tamaño de fuente para etiquetas seleccionadas
            unselectedLabelStyle: TextStyle(fontSize: 14), // Tamaño de fuente para etiquetas no seleccionadas
          ),
        ],
      ),
    );
  }
}