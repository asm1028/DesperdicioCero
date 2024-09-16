import 'package:desperdiciocero/pages/recipes_all.dart';
import 'package:desperdiciocero/pages/recipes_recommendations.dart';
import 'package:flutter/material.dart';

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
            style: TextStyle(color: Colors.black), // Asegúrate de que el título sea visible en el fondo ambar
          ),
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
