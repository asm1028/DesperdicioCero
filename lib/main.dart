import 'package:desperdiciocero/firebase_options.dart';
import 'package:desperdiciocero/pages/home.dart';
import 'package:desperdiciocero/pages/lista_compra.dart';
import 'package:desperdiciocero/pages/login.dart';
import 'package:desperdiciocero/pages/primera_pagina.dart';
import 'package:desperdiciocero/pages/productos.dart';
import 'package:desperdiciocero/pages/lista_productos.dart';
import 'package:desperdiciocero/pages/profile.dart';
import 'package:desperdiciocero/pages/recipes.dart';
import 'package:desperdiciocero/pages/recipes_all.dart';
import 'package:desperdiciocero/pages/recipes_detail.dart';
import 'package:desperdiciocero/pages/recipes_recommendations.dart';
import 'package:desperdiciocero/pages/register.dart';
import 'package:desperdiciocero/pages/user_settings.dart';
import 'package:desperdiciocero/pages/productos_comprados.dart';
import 'package:desperdiciocero/pages/productos_compra.dart';
import 'package:desperdiciocero/utils/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

/// Función principal que inicializa la aplicación.
///
/// Esta función se encarga de realizar las siguientes tareas:
/// - Asegura que los widgets de Flutter estén inicializados.
/// - Inicializa Firebase con las opciones por defecto de la plataforma actual.
/// - Habilita la persistencia de datos en Firestore para permitir el funcionamiento sin conexión.
/// - Inicializa el token del usuario.
/// - Solicita los permisos necesarios antes de iniciar la aplicación.
/// - Inicializa el servicio de notificaciones.
/// - Obtiene la configuración de tema de la aplicación desde las preferencias compartidas.
/// - Crea y ejecuta la aplicación MyApp con el proveedor de tema.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Habilita la persistencia de datos en Firestore para que la app funcione sin conexión
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  await initializeUserToken(); // Llama a la función para inicializar el token del usuario
  await requestPermissions(); // Solicita los permisos necesarios antes de iniciar la app

  NotificationService.initialize(); // Inicializa el servicio de notificaciones
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(isDarkMode: isDarkMode),
      child: MyApp(),
    ),
  );
}

// Función para inicializar el token del usuario solo si es necesario
Future<void> initializeUserToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String userToken = prefs.getString('userToken') ?? '';

  if (userToken.isEmpty) {
    userToken = Uuid().v4();  // Genera un UUID
    await prefs.setString('userToken', userToken);

    // Guarda el token en la base de datos bajo la colección 'users'
    FirebaseFirestore.instance.collection('users').doc(userToken).set({
      'userToken': userToken,
      'created_at': FieldValue.serverTimestamp(),
    });

    // Guarda el token como resguardo
    await prefs.setString('backupToken', userToken);

    print("User Token: $userToken");
  }
}


// Función para solicitar permisos
Future<void> requestPermissions() async {
  final status = await Permission.storage.request();
  if (status.isGranted) {
    // Permiso concedido
    print("Permiso de almacenamiento concedido");
  } else if (status.isDenied) {
    // Permiso denegado
    print("Permiso de almacenamiento denegado");
  } else if (status.isPermanentlyDenied) {
    // El usuario ha denegado permanentemente el permiso; abra la configuración de la app
    openAppSettings();
  }
}

/// Solicita el permiso de alarma exacta si está denegado.
///
/// Si el permiso [Permission.scheduleExactAlarm] está denegado,
/// esta función abre la configuración de la aplicación para que el usuario pueda otorgar el permiso.
///
/// Ejemplo de uso:
/// ```dart
/// await requestExactAlarmPermission();
/// ```
Future<void> requestExactAlarmPermission() async {
  if (await Permission.scheduleExactAlarm.isDenied) {
    // Si el permiso está denegado, solicita permiso
    await openAppSettings(); // O usa otra forma de guiar al usuario para que otorgue permiso
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Rutas para poder viajar entre las diferentes páginas de la aplicación
      home: PrimeraPagina(),
      theme: themeProvider.getTheme,
      routes: {
        'primera_pagina': (context) => PrimeraPagina(),
        '/home': (context) => Home(),
        '/productos': (context) => Productos(),
        '/listaProductos': (context) => ListaProductos(),
        '/settings': (context) => UserSettings(),
        '/profile': (context) => Profile(),
        '/profile/login': (context) => LoginScreen(),
        '/profile/register': (context) => RegisterScreen(),
        '/listaCompra': (context) => ListaCompra(),
        '/productosCompra': (context) => ProductosCompra(),
        '/productosComprados': (context) => ProductosComprados(),
        '/recipes': (context) => RecipesPage(),
        '/recipes/all': (context) => AllRecipes(),
        '/recipes/detail': (context) => RecipeDetail(recipe: ModalRoute.of(context)?.settings.arguments as Map,),
        '/recipes/recommendations': (context) => RecommendationsRecipesPage(),
      },

      // Localización de la aplicación para que salgan los textos en español
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('es', ''), // Español
      ],
    );
  }
}

/// Clase que define los temas de la aplicación.
class AppTheme {
  /// Tema brillante.
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.white,
  );

  /// Tema oscuro.
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.grey[900],
  );
}

/// Clase que maneja el tema de la aplicación.
class ThemeProvider with ChangeNotifier {
  ThemeData _selectedTheme = AppTheme.lightTheme;
  late SharedPreferences prefs;

  /// Constructor de la clase ThemeProvider.
  ///
  /// Inicializa las preferencias y establece el tema seleccionado
  /// basado en el modo oscuro o claro especificado.
  ///
  /// - `isDarkMode`: Un valor booleano que indica si se debe utilizar el modo oscuro.
  ///   Si es `true`, se utilizará el tema oscuro (`AppTheme.darkTheme`).
  ///   Si es `false`, se utilizará el tema claro (`AppTheme.lightTheme`).
  ///
  /// Ejemplo de uso:
  ///
  /// ```dart
  /// ThemeProvider(isDarkMode: true);
  /// ```
  ThemeProvider({required bool isDarkMode}) {
    _initializePreferences();
    _selectedTheme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
  }

  /// Inicializa las preferencias de la aplicación.
  ///
  /// Esta función asincrónica se encarga de inicializar las preferencias de la aplicación
  /// utilizando la clase `SharedPreferences`. Retorna un `Future` que se completa cuando
  /// las preferencias han sido cargadas correctamente.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// await _initializePreferences();
  /// ```
  Future<void> _initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  /// Cambia el tema de la aplicación entre el tema oscuro y el tema claro.
  ///
  /// Si el tema actual es el tema oscuro, cambia al tema claro y guarda la configuración en las preferencias.
  /// Si el tema actual es el tema claro, cambia al tema oscuro y guarda la configuración en las preferencias.
  ///
  /// Luego de cambiar el tema, notifica a los listeners para que se actualicen en consecuencia.
  Future<void> toggleTheme() async {
    if (_selectedTheme == AppTheme.darkTheme) {
      _selectedTheme = AppTheme.lightTheme;
      await prefs.setBool('isDarkMode', false);
    } else {
      _selectedTheme = AppTheme.darkTheme;
      await prefs.setBool('isDarkMode', true);
    }
    notifyListeners();
  }

  ThemeData get getTheme => _selectedTheme;
}