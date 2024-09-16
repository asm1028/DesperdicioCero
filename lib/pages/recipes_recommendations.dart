import 'dart:convert';
import 'package:desperdiciocero/pages/recipes_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecommendationsRecipesPage extends StatefulWidget {
  @override
  _RecommendationsRecipesPageState createState() => _RecommendationsRecipesPageState();
}

class _RecommendationsRecipesPageState extends State<RecommendationsRecipesPage> {
  Future<List<dynamic>> loadRecipes() async {
    final String response = await rootBundle.loadString('lib/assets/recipes.json');
    final data = json.decode(response);
    return data;
  }

  Future<String?> getUserToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }

  Future<List<Map>> findRecipesUsingProducts(List<String> products, Map<String, int> productScores) async {
    final List<dynamic> recipes = await loadRecipes();
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

  String normalizeIngredient(String ingredient) {
    return ingredient.endsWith('s') ? ingredient.substring(0, ingredient.length - 1) : ingredient;
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserToken().then((token) {
        if (token != null) {
          DateTime now = DateTime.now();
          DateTime today = DateTime(now.year, now.month, now.day);
          return FirebaseFirestore.instance
          .collection('products')
          .where('user_token', isEqualTo: token)
          .where('expiration', isGreaterThan: today)  // Asegurarse de que la fecha de caducidad es en el futuro
          .where('expiration', isLessThanOrEqualTo: now.add(Duration(days: 5))) // y dentro de los próximos 5 días
          .get()
          .then((snapshot) {
              List<String> products = [];
              Map<String, int> productScores = {};
              snapshot.docs.forEach((doc) {
                  String productName = normalizeIngredient(doc.data()['name']);
                  products.add(productName);
                  DateTime expiration = doc.data()['expiration'].toDate();
                  int daysUntilExpire = expiration.difference(now).inDays;

                  // Asignar puntuación basada en la proximidad de la fecha de caducidad
                  productScores[productName] = daysUntilExpire >= 0 && daysUntilExpire <= 5 ? 5 : 1;
              });
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
