import 'package:desperdiciocero/pages/recipes_all.dart';
import 'package:desperdiciocero/pages/recipes_recommendations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Página de recetas.
///
/// Esta clase representa la página de recetas en la aplicación.
/// Es un StatefulWidget que muestra una lista de recetas.
///
/// Ejemplo de uso:
///
/// ```dart
/// RecipesPage(
///   key: UniqueKey(),
/// )
/// ```
class RecipesPage extends StatefulWidget {
  RecipesPage({super.key});

  @override
  _RecipesPageState createState() => _RecipesPageState();
}

/// Clase que representa la página de recetas.
///
/// Esta clase es responsable de mostrar la página de recetas en la aplicación.
/// Contiene una barra de navegación superior con pestañas para mostrar todas las recetas y las recomendaciones.
/// También muestra un diálogo de información cuando se presiona el botón de información en la barra de navegación.
class _RecipesPageState extends State<RecipesPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Recetas',
            style: TextStyle(color: Colors.black),
          ),
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
                        'Aquí puedes encontrar todas las recetas disponibles y las recomendaciones personalizadas según que productos tengas almacenados y a punto de caducar.',
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
          backgroundColor: Colors.amber,
          bottom: TabBar(
            labelColor: Colors.black, // Color de texto activo
            unselectedLabelColor: Colors.grey[800], // Color de texto inactivo
            tabs: [
              Tab(text: 'Todas las Recetas'),
              Tab(text: 'Recomendaciones'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AllRecipes(), // Para la pestaña de Todas las Recetas
            RecommendationsRecipesPage(), // Para la pestaña de Recomendaciones
          ],
        ),
      ),
    );
  }
}
