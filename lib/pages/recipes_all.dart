import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class AllRecipes extends StatelessWidget {
  Future<List<dynamic>> loadRecipes() async {
    final String response = await rootBundle.loadString('lib/assets/recipes.json');
    final data = json.decode(response);
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadRecipes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          List? recipes = snapshot.data;
          return ListView.builder(
            itemCount: recipes?.length,
            itemBuilder: (context, index) {
              var recipe = recipes?[index];
              return ListTile(
                title: Text(recipe['nombre']),
                onTap: () {
                  Navigator.pushNamed(context, '/recipes/detail', arguments: recipe);
                },
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
