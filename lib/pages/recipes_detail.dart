import 'package:flutter/material.dart';

/// Esta clase representa la página de detalles de una receta.
class RecipeDetail extends StatelessWidget {
  final Map recipe;

  RecipeDetail({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    String recipeName = recipe['nombre'] as String? ?? 'Nombre no disponible';

    return Scaffold(
      appBar: AppBar(
        title: Text(recipeName, style: TextStyle(fontSize: 24, color: Colors.black)),
        backgroundColor: Colors.amber,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Ingredientes",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Divider(),
              ..._buildIngredientList(recipe['ingredientes'] as List? ?? [], recipe['cantidades'] as List? ?? []),
              SizedBox(height: 20),
              Text(
                "Pasos",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Divider(),
              ..._buildStepList(recipe['pasos'] as List? ?? []),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye una lista de widgets que representan los ingredientes y las cantidades.
  ///
  /// Recibe dos listas, [ingredients] y [quantities], que contienen los ingredientes y las cantidades respectivamente.
  /// Itera sobre ambas listas y crea un widget [Row] para cada par de ingrediente y cantidad.
  /// Dentro de cada [Row], se muestra un punto ('·') seguido de un espacio en blanco, y luego se muestra la cantidad.
  /// Si el texto de la cantidad es muy largo y no cabe en la pantalla, se muestra completo sin truncar.
  ///
  /// Retorna una lista de widgets que representan los ingredientes y las cantidades.
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

  /// Construye una lista de widgets que representan los pasos de una receta.
  ///
  /// Recibe una lista de pasos y devuelve una lista de widgets que contienen
  /// cada paso de la receta. Cada widget de paso consiste en un texto que
  /// muestra el número del paso y la descripción del mismo, seguido de un
  /// espacio en blanco y una línea divisoria.
  ///
  /// Ejemplo de uso:
  ///
  /// ```dart
  /// List<Widget> steps = ['Mezclar los ingredientes', 'Hornear durante 30 minutos'];
  /// List<Widget> stepWidgets = _buildStepList(steps);
  /// ```
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
