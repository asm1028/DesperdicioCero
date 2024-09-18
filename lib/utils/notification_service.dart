import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

/// Clase que proporciona servicios de notificación.
class NotificationService {
  /// Plugin de notificaciones locales de Flutter.
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializa el servicio de notificaciones.
  static void initialize() {
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        );

    _notificationsPlugin.initialize(initializationSettings);
    _configureDailyCheck();
  }

  /// Muestra una notificación.
  ///
  /// - [id]: El ID de la notificación.
  /// - [title]: El título de la notificación.
  /// - [body]: El cuerpo de la notificación.
  static Future<void> showNotification(int id, String title, String body) async {
    await _notificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'channelId',
          'channelName',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  /// Configura la comprobación diaria.
  static Future<void> _configureDailyCheck() async {
    await AndroidAlarmManager.initialize();
    await AndroidAlarmManager.periodic(
      const Duration(days: 1), // Cada día
      982, // ID único para esta alarma
      checkExpiryDates,
    );
  }

  /// Comprueba las fechas de caducidad.
  static Future<void> checkExpiryDates() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userToken = prefs.getString('userToken');
    if (userToken == null) {
      return; // Si no hay token, no hacemos nada.
    }

    final DateTime now = DateTime.now();
    final querySnapshot = await FirebaseFirestore.instance
      .collection('products')
      .where('user_token', isEqualTo: userToken)
      .where('expiration', isLessThanOrEqualTo: now.add(Duration(days: 1)))
      .get();

    List<String> expiringProducts = [];
    for (final document in querySnapshot.docs) {
      final product = document.data();
      final expiryDate = (product['expiration'] as Timestamp).toDate();
      if (expiryDate.difference(now).inDays == 0) {
        expiringProducts.add(product['name']);
      }
    }

    if (expiringProducts.isNotEmpty) {
      if (expiringProducts.length == 1) {
        print("Sending notification for one expiring product: ${expiringProducts.first}");
        showNotification(
          982,
          "Producto a punto de caducar",
          "Tu ${expiringProducts.first} caduca hoy!"
        );
      } else {
        print("Sending notification for multiple expiring products.");
        showNotification(
          982,
          "Productos a punto de caducar",
          "Varios productos están a punto de caducar hoy!"
        );
      }
    }
  }
}
