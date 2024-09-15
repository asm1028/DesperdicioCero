import 'package:desperdiciocero/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserSettings extends StatelessWidget {
  UserSettings({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener la instancia del proveedor de tema
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ajustes', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 149, 144, 144),
      ),
      body: ListView(  // Cambiado a ListView para permitir más configuraciones en el futuro
        children: [
          Padding(
            padding: const EdgeInsets.all(30.0),
          ),
          SwitchListTile(
            title: Text('Modo Oscuro'),
            subtitle: Text('Activa el modo oscuro en la aplicación'),
            value: themeProvider.getTheme == AppTheme.darkTheme,
            onChanged: (bool value) {
              themeProvider.toggleTheme();
            },
            secondary: Icon(themeProvider.getTheme == AppTheme.darkTheme ? Icons.dark_mode : Icons.light_mode),
          ),
        ],
      ),
    );
  }
}
