import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/utils/logger.dart';

typedef BookingPayload = Map<String, dynamic>;

class BookingQueueService {
  static const String bookingQueueBox = 'booking_queue_box';

  Future<void> init() async {
    if (!Hive.isBoxOpen(bookingQueueBox)) {
      await Hive.openBox<String>(bookingQueueBox);
    }
  }

  Future<void> enqueue(BookingPayload payload) async {
    final box = Hive.box<String>(bookingQueueBox);
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await box.put(id, jsonEncode(payload));
    AppLogger.info('Queued booking: $id');
  }

  List<MapEntry<String, BookingPayload>> getAll() {
    if (!Hive.isBoxOpen(bookingQueueBox)) return <MapEntry<String, BookingPayload>>[];
    final box = Hive.box<String>(bookingQueueBox);
    final Map<String, String> all = box.toMap().map((k, v) => MapEntry(k as String, v));
    final List<MapEntry<String, BookingPayload>> result = [];
    for (final entry in all.entries) {
      try {
        final decoded = jsonDecode(entry.value) as Map<String, dynamic>;
        if (decoded.isNotEmpty) {
          result.add(MapEntry(entry.key, decoded));
        }
      } catch (_) {
        // skip malformed entries
      }
    }
    return result;
  }

  Future<void> remove(String id) async {
    final box = Hive.box<String>(bookingQueueBox);
    await box.delete(id);
  }
}


