import 'package:flutter/material.dart';

class RecipeDetail extends StatelessWidget {
  final Map recipe;

  // Constructor que recibe la receta
  RecipeDetail({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['nombre']),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Ingredientes",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(),
              ..._buildIngredientList(recipe['ingredientes'], recipe['cantidades']),
              SizedBox(height: 20),
              Text(
                "Pasos",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(),
              ..._buildStepList(recipe['pasos']),
            ],
          ),
        ),
      ),
    );
  }

  // Función para construir la lista de ingredientes
  List<Widget> _buildIngredientList(List ingredients, List quantities) {
    List<Widget> list = [];
    for (int i = 0; i < ingredients.length; i++) {
      list.add(
        Text('${quantities[i]} de ${ingredients[i]}'),
      );
    }
    return list;
  }

  // Función para construir la lista de pasos
  List<Widget> _buildStepList(List steps) {
    List<Widget> list = [];
    for (int i = 0; i < steps.length; i++) {
      list.add(
        Text('Paso ${i + 1}: ${steps[i]}', style: TextStyle(height: 1.5)),
      );
    }
    return list;
  }
}
