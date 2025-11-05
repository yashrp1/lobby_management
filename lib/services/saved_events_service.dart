import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SavedEventsService {
  static const String _key = 'saved_events';

  static Future<Set<String>> getSavedEventIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return <String>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toSet();
      }
    } catch (_) {}
    return <String>{};
  }

  static Future<bool> isSaved(String eventId) async {
    final ids = await getSavedEventIds();
    return ids.contains(eventId);
  }

  static Future<void> toggleSaved(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getSavedEventIds();
    if (ids.contains(eventId)) {
      ids.remove(eventId);
    } else {
      ids.add(eventId);
    }
    await prefs.setString(_key, jsonEncode(ids.toList()));
  }
}


