import 'package:desperdiciocero/pages/recipes_detail.dart';
import 'package:desperdiciocero/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Página de recomendaciones de recetas.
///
/// Esta clase representa la página de recomendaciones de recetas en la aplicación.
/// Es un StatefulWidget, lo que significa que puede tener un estado mutable.
/// El estado de esta página está representado por la clase [_RecommendationsRecipesPageState].
class RecommendationsRecipesPage extends StatefulWidget {
  @override
  _RecommendationsRecipesPageState createState() => _RecommendationsRecipesPageState();
}

/// Estado de la página de recomendaciones de recetas.
class _RecommendationsRecipesPageState extends State<RecommendationsRecipesPage> {

  /// Encuentra recetas que utilicen los productos dados y calcula su puntuación.
  ///
  /// Esta función toma una lista de productos y un mapa de puntuaciones de productos como entrada.
  /// Luego, carga una lista de recetas y busca aquellas que contengan los ingredientes de los productos dados.
  /// Calcula la puntuación de cada receta en función de la cantidad de ingredientes coincidentes y sus puntuaciones correspondientes.
  /// Las recetas se ordenan en función de su puntuación y se devuelve una lista con las 3 mejores recetas.
  ///
  /// - `products`: Una lista de cadenas que representa los productos a buscar en las recetas.
  /// - `productScores`: Un mapa que asigna puntuaciones a los productos.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// List<String> products = ['manzana', 'naranja', 'plátano'];
  /// Map<String, int> productScores = {'manzana': 5, 'naranja': 3, 'plátano': 2};
  /// List<Map> recommendedRecipes = await findRecipesUsingProducts(products, productScores);
  /// ```
  Future<List<Map>> findRecipesUsingProducts(List<String> products, Map<String, int> productScores) async {
    final List<dynamic> recipes = await Utils().loadRecipes();
    List<Map> scoredRecipes = [];

    for (var recipe in recipes) {
      int totalScore = 0;
      int ingredientCount = 0;

      for (var ingredient in recipe['ingredientes']) {
        String normalizedIngredient = normalizeIngredient(ingredient);
        if (products.contains(normalizedIngredient)) {
          totalScore += productScores[normalizedIngredient] ?? 0;
          ingredientCount++;
        }
      }

      double score = ingredientCount > 0 ? totalScore * (ingredientCount / recipe['ingredientes'].length) : 0;
      if (score > 0) {
        scoredRecipes.add({'recipe': recipe, 'score': score});
      }
    }

    scoredRecipes.sort((a, b) => b['score'].compareTo(a['score']));
    return scoredRecipes.take(3).toList(); // Top 3 recipes
  }

  /// Normaliza un ingrediente eliminando la 's' al final si existe.
  ///
  /// [ingredient] - El ingrediente a normalizar.
  ///
  /// Retorna el ingrediente normalizado.
  String normalizeIngredient(String ingredient) {
    return ingredient.endsWith('s') ? ingredient.substring(0, ingredient.length - 1) : ingredient;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Utils().getUserToken().then((token) {
        if (token != null) {
          DateTime now = DateTime.now();
          DateTime today = DateTime(now.year, now.month, now.day);
          return FirebaseFirestore.instance
          .collection('products')
          .where('user_token', isEqualTo: token) // Busca los productos del usuario actual
          .where('expiration', isGreaterThan: today)  // y que no hayan caducado todavía
          .where('expiration', isLessThanOrEqualTo: now.add(Duration(days: 5))) // y dentro de los próximos 5 días
          .get()
          .then((snapshot) {
              List<String> products = [];
              Map<String, int> productScores = {};
              for (var doc in snapshot.docs) {
                  String productName = normalizeIngredient(doc.data()['name']);
                  products.add(productName);
                  DateTime expiration = doc.data()['expiration'].toDate();
                  int daysUntilExpire = expiration.difference(now).inDays;

                  // Asigna la puntuación basada en la proximidad de la fecha de caducidad
                  productScores[productName] = daysUntilExpire >= 0 && daysUntilExpire <= 5 ? 5 : 1;
              }
              return findRecipesUsingProducts(products, productScores);
          });
        } else {
          throw Exception("User token not found");
        }
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
          List<Map>? recipes = snapshot.data;
          if (recipes == null || recipes.isEmpty) {
            return Center(
              child: Container(
              margin: EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                "No se ha encontrado una receta que se ajuste a los ingredientes que tienes almacenados.",
                style: TextStyle(fontSize: 16),
              ),
              ),
            );
          }
          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              var recipe = recipes[index]['recipe'];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                elevation: 4,
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(recipe['nombre'], style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetail(recipe: recipe),
                      ),
                    );
                  },
                ),
              );
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
