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
          // Nos aseguramos de que snapshot.data es no-nulo antes de usarlo
          if (snapshot.data == null) {
            return Center(child: Text("No se encontraron recetas"));
          }
          List recipes = snapshot.data as List; // Casting seguro ya que comprobamos nulos antes
          return ListView(
            children: recipes.map<Widget>((recipe) {
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                elevation: 4,
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  title: Text(recipe['nombre'] ?? 'Receta sin nombre', // Manejo de nulos
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('Click para ver detalles'), // Puedes ajustar o eliminar este texto
                  onTap: () {
                    // Navegar a una nueva página para mostrar detalles
                    Navigator.pushNamed(context, '/recipes/detail', arguments: recipe);
                  },
                ),
              );
            }).toList(),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
