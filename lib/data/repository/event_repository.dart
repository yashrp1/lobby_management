import '../datasources/event_remote_datasource.dart';
import '../models/event_detail_model.dart';

abstract class EventRepository {
  Future<EventDetailModel> getEventDetail(String eventId, String? token);
}

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;

  EventRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<EventDetailModel> getEventDetail(String eventId, String? token) async {
    try {
      return await remoteDataSource.getEventDetail(eventId, token);
    } catch (e) {
      rethrow;
    }
  }
}
