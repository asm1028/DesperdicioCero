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

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.white,
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.grey[900],
  );
}

class ThemeProvider with ChangeNotifier {
  ThemeData _selectedTheme = AppTheme.lightTheme;
  late SharedPreferences prefs;

  ThemeProvider({required bool isDarkMode}) {
    _initializePreferences();
    _selectedTheme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
  }

  Future<void> _initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

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