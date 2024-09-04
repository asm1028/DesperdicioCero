import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class AllRecipes extends StatelessWidget {

  /// Función que carga las recetas desde un fichero JSON.
  ///
  /// Esta función lee las recetas que están ubicadas en la ruta 'lib/assets/recipes.json'
  /// y decodea dicha receta en una lista de objetos dinámicos.
  /// Y gracias a que la receta está en formato JSON, podemos acceder a sus atributos fácilmente
  ///
  /// Devuelve una lista de objetos dinámicos que representan las recetas cargadas.
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
          // Asegurarse de que snapshot.data es no-nulo antes de usarlo
          if (snapshot.data == null) {
            return Center(child: Text("No se encontraron recetas"));
          }
          List recipes = snapshot.data as List; // Casting seguro ya que comprobamos nulos antes
          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              var recipe = recipes[index];
              return ListTile(
                title: Text(recipe['nombre'] ?? 'Receta sin nombre'), // Uso de ?? para manejar nulos
                onTap: () {
                  // Aseguramos que la receta no sea nula antes de entrar en la página de dicha receta
                  if (recipe != null) {
                    Navigator.pushNamed(context, '/recipes/detail', arguments: recipe);
                  }
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
