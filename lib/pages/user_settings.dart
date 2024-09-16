import 'package:desperdiciocero/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettings extends StatelessWidget {
  UserSettings({super.key});

  Future<void> updateThreshold(BuildContext context, String key, int currentValue) async {
    final TextEditingController controller = TextEditingController(text: currentValue.toString());
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Actualizar Umbral'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Ingresa el número de días",
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Guardar'),
            onPressed: () async {
              final int? newThreshold = int.tryParse(controller.text);
              if (newThreshold != null) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setInt(key, newThreshold);
                Navigator.of(context).pop();
                Provider.of<ThemeProvider>(context, listen: false).notifyListeners();  // Actualiza a tiempo real la variable al guardar
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener la instancia del proveedor de tema
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajustes', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 149, 144, 144),
      ),
      body: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          final prefs = snapshot.data!;
          final int oneDayThreshold = prefs.getInt('oneDayThreshold') ?? 1;
          final int fiveDayThreshold = prefs.getInt('fiveDayThreshold') ?? 5;

          return ListView(
        children: [
          Padding(padding: const EdgeInsets.all(16.0),),
          SwitchListTile(
            title: Text('Modo Oscuro'),
            subtitle: Text('Activa el modo oscuro en la aplicación'),
            value: themeProvider.getTheme == AppTheme.darkTheme,
            onChanged: (bool value) {
              themeProvider.toggleTheme();
            },
            secondary: Icon(themeProvider.getTheme == AppTheme.darkTheme ? Icons.dark_mode : Icons.light_mode),
          ),
              ListTile(
                title: Text('Días para el umbral "Caduca mañana"'),
                trailing: Text('$oneDayThreshold días'),
                onTap: () => updateThreshold(context, 'oneDayThreshold', oneDayThreshold),
              ),
              ListTile(
                title: Text('Días para el umbral "Caduca en 2 a 5 días"'),
                trailing: Text('$fiveDayThreshold días'),
                onTap: () => updateThreshold(context, 'fiveDayThreshold', fiveDayThreshold),
              ),
            ],
          );
        },
      ),
    );
  }
}
