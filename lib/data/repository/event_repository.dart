import '../datasources/event_remote_datasource.dart';
import '../models/event_detail_model.dart';
import '../../services/local_event_cache_service.dart';
import '../../core/utils/api_exception.dart';

abstract class EventRepository {
  Future<EventDetailModel> getEventDetail(String eventId, String? token);
  Future<void> bookTicket({
    required String eventId,
    required String ticketId,
    required int quantity,
    String? token,
  });
}

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;
  final LocalEventCacheService localCache;

  EventRepositoryImpl({
    required this.remoteDataSource,
    required this.localCache,
  });

  @override
  Future<EventDetailModel> getEventDetail(String eventId, String? token) async {
    try {
      final event = await remoteDataSource.getEventDetail(eventId, token);
      // Cache latest JSON by reconstructing from model is non-trivial, so rely on API cache: not available here.
      // As a compromise, we re-fetch the JSON by encoding fields we have.
      // Prefer: let remote layer pass JSON. For now, we encode minimally.
      final json = {
        'lobby': {
          'id': event.lobby.id,
          'title': event.lobby.title,
          'description': event.lobby.description,
          'mediaUrls': event.lobby.mediaUrls,
          'lobbyStatus': event.lobby.lobbyStatus,
          'filter': null,
          'totalMembers': event.lobby.totalMembers,
          'currentMembers': event.lobby.currentMembers,
          'membersRequired': event.lobby.membersRequired,
          'isPaid': event.lobby.isPaid,
          'locations': event.lobby.locations
              .map((e) => {'lat': e.lat, 'lon': e.lon})
              .toList(),
          'adminSummary': null,
          'dateRange': event.lobby.dateRange == null
              ? null
              : {
                  'startDate': event.lobby.dateRange!.startDate,
                  'endDate': event.lobby.dateRange!.endDate,
                  'formattedDate': event.lobby.dateRange!.formattedDate,
                },
          'activity': event.lobby.activity,
          'statusFlag': event.lobby.statusFlag,
          'houseId': event.lobby.houseId,
          'houseDetail': null,
          'form': null,
          'hasForm': event.lobby.hasForm,
          'priceDetails': null,
          'admins': event.lobby.admins,
          'ticketOptions': event.lobby.ticketOptions
              .map((t) => {
                    'id': t.id,
                    'name': t.name,
                    'description': t.description,
                    'price': t.price,
                    'strikePrice': t.strikePrice,
                    'totalSlots': t.totalSlots,
                    'bookedSlots': t.bookedSlots,
                    'currency': t.currency,
                    'minQuantity': t.minQuantity,
                    'maxQuantity': t.maxQuantity,
                    'activity': t.activity,
                  })
              .toList(),
          'views': event.lobby.views,
          'lobbyInsight': null,
          'userSummaries': event.lobby.userSummaries
              .map((u) => {
                    'userId': u.userId,
                    'name': u.name,
                    'email': u.email,
                    'mobile': u.mobile,
                  })
              .toList(),
        },
        'category': {
          'id': event.category.id,
          'name': event.category.name,
          'description': event.category.description,
          'iconUrl': event.category.iconUrl,
        },
        'subCategory': {
          'id': event.subCategory.id,
          'name': event.subCategory.name,
          'description': event.subCategory.description,
          'iconUrl': event.subCategory.iconUrl,
        },
      };
      await localCache.saveEventJson(eventId, json);
      return event;
    } on ApiException {
      final cached = localCache.getEventJson(eventId);
      if (cached != null) {
        return EventDetailModel.fromJson(cached);
      }
      rethrow;
    } catch (_) {
      final cached = localCache.getEventJson(eventId);
      if (cached != null) {
        return EventDetailModel.fromJson(cached);
      }
      rethrow;
    }
  }

  @override
  Future<void> bookTicket({
    required String eventId,
    required String ticketId,
    required int quantity,
    String? token,
  }) async {
    await remoteDataSource.bookTicket(
      eventId: eventId,
      ticketId: ticketId,
      quantity: quantity,
      token: token,
    );
  }
}
