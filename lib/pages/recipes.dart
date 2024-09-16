import 'package:desperdiciocero/pages/recipes_all.dart';
import 'package:desperdiciocero/pages/recipes_recommendations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RecipesPage extends StatefulWidget {
  RecipesPage({super.key});

  @override
  _RecipesPageState createState() => _RecipesPageState();
}

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
