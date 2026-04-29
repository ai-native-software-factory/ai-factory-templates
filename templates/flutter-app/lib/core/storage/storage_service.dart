import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage service for persistent data
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  late SharedPreferences _prefs;
  late Directory _appDirectory;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize storage service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    _appDirectory = await getApplicationDocumentsDirectory();

    _isInitialized = true;
    debugPrint('StorageService initialized');
  }

  /// Get SharedPreferences instance
  SharedPreferences get prefs => _prefs;

  /// Get app documents directory
  Directory get appDirectory => _appDirectory;

  // String operations
  Future<bool> setString(String key, String value) async {
    return _prefs.setString(key, value);
  }

  String? getString(String key, {String? defaultValue}) {
    return _prefs.getString(key) ?? defaultValue;
  }

  // Int operations
  Future<bool> setInt(String key, int value) async {
    return _prefs.setInt(key, value);
  }

  int? getInt(String key, {int? defaultValue}) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  // Double operations
  Future<bool> setDouble(String key, double value) async {
    return _prefs.setDouble(key, value);
  }

  double? getDouble(String key, {double? defaultValue}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  // Bool operations
  Future<bool> setBool(String key, bool value) async {
    return _prefs.setBool(key, value);
  }

  bool? getBool(String key, {bool? defaultValue}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  // List<String> operations
  Future<bool> setStringList(String key, List<String> value) async {
    return _prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  // JSON operations
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return _prefs.setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getJson(String key) {
    final str = _prefs.getString(key);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error decoding JSON for key $key: $e');
      return null;
    }
  }

  // Remove and clear
  Future<bool> remove(String key) async {
    return _prefs.remove(key);
  }

  Future<bool> clear() async {
    return _prefs.clear();
  }

  // Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // Get all keys
  Set<String> getKeys() {
    return _prefs.getKeys();
  }

  /// Write file to app documents directory
  Future<File> writeFile(String fileName, String content) async {
    final file = File('${_appDirectory.path}/$fileName');
    return file.writeAsString(content);
  }

  /// Read file from app documents directory
  Future<String?> readFile(String fileName) async {
    try {
      final file = File('${_appDirectory.path}/$fileName');
      if (await file.exists()) {
        return file.readAsString();
      }
    } catch (e) {
      debugPrint('Error reading file $fileName: $e');
    }
    return null;
  }

  /// Delete file from app documents directory
  Future<bool> deleteFile(String fileName) async {
    try {
      final file = File('${_appDirectory.path}/$fileName');
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting file $fileName: $e');
    }
    return false;
  }

  /// Get file path
  String getFilePath(String fileName) {
    return '${_appDirectory.path}/$fileName';
  }
}
