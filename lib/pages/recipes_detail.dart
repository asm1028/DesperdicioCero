import 'package:flutter/material.dart';

class RecipeDetail extends StatelessWidget {
  final Map recipe;

  RecipeDetail({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    String recipeName = recipe['nombre'] as String? ?? 'Nombre no disponible';

    return Scaffold(
      appBar: AppBar(
        title: Text(recipeName, style: TextStyle(fontSize: 24)),
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
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),  // Aumentar tamaño y negrita para "Ingredientes"
              ),
              Divider(),
              ..._buildIngredientList(recipe['ingredientes'] as List? ?? [], recipe['cantidades'] as List? ?? []),
              SizedBox(height: 20),
              Text(
                "Pasos",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),  // Aumentar tamaño y negrita para "Pasos"
              ),
              Divider(),
              ..._buildStepList(recipe['pasos'] as List? ?? []),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildIngredientList(List ingredients, List quantities) {
    List<Widget> list = [];
    for (int i = 0; i < ingredients.length && i < quantities.length; i++) {
      list.add(
        Row(
          children: [
            Text('·', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '${quantities[i]}',
                style: TextStyle(fontSize: 18),
                // En caso de que el texto sea muy largo y no quepa en la pantalla, que se muestre completo
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      );
    }
    return list;
  }

  List<Widget> _buildStepList(List steps) {
    List<Widget> list = [];
    for (int i = 0; i < steps.length; i++) {
      list.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paso ${i + 1}: ${steps[i]}', style: TextStyle(fontSize: 18, height: 1.5)),  // Aumentar el tamaño del texto de los pasos
            SizedBox(height: 8),
            Divider(),
          ],
        ),
      );
    }
    return list;
  }
}
