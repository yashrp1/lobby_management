import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class LocalEventCacheService {
  static const String eventCacheBox = 'event_cache_box';

  Future<void> init() async {
    if (!Hive.isBoxOpen(eventCacheBox)) {
      await Hive.openBox<String>(eventCacheBox);
    }
  }

  Future<void> saveEventJson(String eventId, Map<String, dynamic> json) async {
    final box = Hive.box<String>(eventCacheBox);
    await box.put(eventId, jsonEncode(json));
  }

  Map<String, dynamic>? getEventJson(String eventId) {
    if (!Hive.isBoxOpen(eventCacheBox)) return null;
    final box = Hive.box<String>(eventCacheBox);
    final raw = box.get(eventId);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}


