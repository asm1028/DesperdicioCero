import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';

class Home extends StatelessWidget {
  Home({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DesperdicioCero',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.greenAccent[400],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.greenAccent,
              ),
              child: Text(
                '\nBienvenido a DesperdicioCero!'
                '\n\nDesarrollado por: \n'
                'Alberto Santos Martínez',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('A J U S T E S'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/settings',
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('P E R F I L'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/profile',
                );
              },
            ),
          ],
        ),
      ),
  
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Página principal\n\n\n\n'
              'En esta interfaz se pondrán\n'
              'los productos más proximos\n'
              'a caducar y los productos que\n'
              'el usuario tiene en la lista\n'
              'de la compra\n',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //final image = await ImagePicker().getImage(source: ImageSource.camera);
        },
        backgroundColor: Colors.greenAccent[400],
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
