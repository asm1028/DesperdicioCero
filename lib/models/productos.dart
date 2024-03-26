import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  final Database _database;

  DatabaseHelper._internal(this._database);

  static late final Future<DatabaseHelper> _instance = _initDatabase().then((database) => DatabaseHelper._internal(database));

  // factory DatabaseHelper() {
  //   return _instance;
  // }

  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "productos.db");

    final database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Productos (
            id INTEGER PRIMARY KEY,
            nombre_producto TEXT,
            fecha_caducidad DATE
          )
        ''');
      },
    );

    return database;
  }

  Future<Database> get database async {
    return _database;
  }

  Future<List<Map<String, dynamic>>> getProductos() async {
    try {
      final db = await database;
      return await db.query('Productos');
    } catch (e) {
      print("Error al obtener los productos: $e");
      return [];
    }
  }

  Future<void> insertProducto(Map<String, dynamic> producto) async {
    try {
      final db = await database;
      await db.insert('Productos', producto);
    } catch (e) {
      print("Error al insertar el producto: $e");
    }
  }

  // Agrega más métodos según sea necesario para realizar otras operaciones CRUD
}
