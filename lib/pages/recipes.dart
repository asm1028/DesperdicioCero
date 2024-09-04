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
          title: Text('Recetas'),
          backgroundColor: Colors.amber,
          bottom: TabBar(
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
