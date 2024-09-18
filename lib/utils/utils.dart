import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

/// Clase de códigos repetidos.
class Utils {

  /// Obtiene el token de usuario almacenado en las preferencias compartidas.
  ///
  /// Retorna el token de usuario como una cadena de texto o null si no se encuentra disponible.
  ///
  /// Ejemplo de uso:
  ///
  /// ```dart
  /// String? token = await getUserToken();
  /// ```
  Future<String?> getUserToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }

  /// Carga las recetas desde un archivo JSON y devuelve una lista de objetos dinámicos.
  ///
  /// Esta función asincrónica utiliza el método `rootBundle.loadString` para cargar el contenido del archivo `recipes.json`
  /// ubicado en la ruta `lib/assets/recipes.json`. Luego, decodifica el contenido JSON utilizando el método `json.decode`
  /// y devuelve los datos como una lista de objetos dinámicos.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// Future<List<dynamic>> recipes = loadRecipes();
  /// ```
  Future<List<dynamic>> loadRecipes() async {
    final String response = await rootBundle.loadString('lib/assets/recipes.json');
    final data = json.decode(response);
    return data;
  }

}