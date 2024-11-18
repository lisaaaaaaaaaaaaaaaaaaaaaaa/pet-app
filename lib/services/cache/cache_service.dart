import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheService {
  static final SharedPreferences _prefs = await SharedPreferences.getInstance();
  
  Future<void> set(String key, dynamic value) async {
    await _prefs.setString(key, json.encode(value));
  }
  
  Future<dynamic> get(String key) async {
    final value = _prefs.getString(key);
    return value != null ? json.decode(value) : null;
  }
  
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
  
  Future<void> clear() async {
    await _prefs.clear();
  }
}
