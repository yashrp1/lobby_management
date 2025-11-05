import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'logger.dart';

/// Secure storage utility for sensitive data
class SecureStorage {
  static const _storage = FlutterSecureStorage();

  /// Store sensitive data securely (tokens, keys, etc.)
  static Future<void> writeSecure(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      AppLogger.debug('Securely stored: $key');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to store secure data: $key', e, stackTrace);
      rethrow;
    }
  }

  /// Read sensitive data
  static Future<String?> readSecure(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to read secure data: $key', e, stackTrace);
      return null;
    }
  }

  /// Delete sensitive data
  static Future<void> deleteSecure(String key) async {
    try {
      await _storage.delete(key: key);
      AppLogger.debug('Deleted secure data: $key');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete secure data: $key', e, stackTrace);
    }
  }

  /// Store non-sensitive data (preferences, cache keys, etc.)
  static Future<void> write(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to store data: $key', e, stackTrace);
    }
  }

  /// Read non-sensitive data
  static Future<String?> read(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to read data: $key', e, stackTrace);
      return null;
    }
  }

  /// Delete non-sensitive data
  static Future<void> delete(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete data: $key', e, stackTrace);
    }
  }
}

