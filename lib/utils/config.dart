library config;

import 'package:shared_preferences/shared_preferences.dart';

String? baseUrl;

Future<void> initConfig() async {
  final prefs = await SharedPreferences.getInstance();
  baseUrl = prefs.getString('base_url');
  print('[CONFIG] initConfig ejecutado, baseUrl = $baseUrl');
}
