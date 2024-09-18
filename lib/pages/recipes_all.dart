import 'package:desperdiciocero/utils/utils.dart';
import 'package:flutter/material.dart';

/// Esta clase representa la página de todas las recetas.
class AllRecipes extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Utils().loadRecipes(),
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
