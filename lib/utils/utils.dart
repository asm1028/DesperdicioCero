import 'package:shared_preferences/shared_preferences.dart';

class Utils {

  Future<String?> getUserToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }
}