import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/api_exception.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/performance_monitor.dart';
import '../../core/utils/validators.dart';
import '../models/event_detail_model.dart';

abstract class EventRemoteDataSource {
  Future<EventDetailModel> getEventDetail(String eventId, String? token);
  Future<void> bookTicket({
    required String eventId,
    required String ticketId,
    required int quantity,
    String? token,
  });
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final Dio dio;

  EventRemoteDataSourceImpl({required this.dio});

  @override
  Future<EventDetailModel> getEventDetail(String eventId, String? token) async {
    // Validate input
    if (!Validators.isValidEventId(eventId)) {
      AppLogger.error('Invalid event ID format: $eventId');
      throw const ApiException(message: 'Invalid event ID format');
    }

    if (token != null && !Validators.isValidToken(token)) {
      AppLogger.warning('Token format validation failed');
    }

    return PerformanceMonitor.measure('getEventDetail', () async {
      try {
        final url = '${ApiConstants.baseUrl}${ApiConstants.getEventDetailUrl(eventId)}';
        final headers = ApiConstants.getHeaders(token);
        
        AppLogger.apiRequest('GET', url, headers);
        
        final response = await dio.get(
          url,
          options: Options(headers: headers),
        );

        AppLogger.apiResponse(response.statusCode ?? 0, url);

        if (response.statusCode == 200) {
          if (response.data is Map<String, dynamic>) {
            try {
              final event = EventDetailModel.fromJson(response.data);
              AppLogger.info('Successfully loaded event: ${event.lobby.id}');
              return event;
            } catch (e, stackTrace) {
              AppLogger.error('Failed to parse event data', e, stackTrace);
              throw const ServerException(message: 'Failed to parse response data');
            }
          } else {
            AppLogger.error('Invalid response format: ${response.data.runtimeType}');
            throw const ServerException(message: 'Invalid response format');
          }
        } else if (response.statusCode == 401) {
          AppLogger.warning('Unauthorized access to event: $eventId');
          throw const UnauthorizedException();
        } else if (response.statusCode == 404) {
          AppLogger.warning('Event not found: $eventId');
          throw const NotFoundException();
        } else {
          AppLogger.error('Server error: ${response.statusCode}');
          throw ServerException(
            message: 'Server error',
            statusCode: response.statusCode,
          );
        }
      } on DioException catch (e, stackTrace) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          AppLogger.error('Connection timeout', e, stackTrace);
          throw const NetworkException(message: 'Connection timeout');
        } else if (e.type == DioExceptionType.connectionError) {
          AppLogger.error('Connection error - no internet', e, stackTrace);
          throw const NetworkException();
        } else if (e.response != null) {
          final statusCode = e.response!.statusCode;
          final requestUrl = e.requestOptions.uri.toString();
          AppLogger.apiResponse(statusCode ?? 0, requestUrl);
          
          if (statusCode == 401) {
            throw const UnauthorizedException();
          } else if (statusCode == 404) {
            throw const NotFoundException();
          }
          throw ServerException(
            message: e.response?.data?['message'] ?? 'Server error',
            statusCode: statusCode,
          );
        } else {
          AppLogger.error('Dio error: ${e.message}', e, stackTrace);
          throw ApiException(message: e.message ?? 'An error occurred');
        }
      } catch (e, stackTrace) {
        if (e is ApiException) {
          rethrow;
        }
        AppLogger.error('Unexpected error in getEventDetail', e, stackTrace);
        throw ApiException(message: e.toString());
      }
    });
  }

  @override
  Future<void> bookTicket({
    required String eventId,
    required String ticketId,
    required int quantity,
    String? token,
  }) async {
    // Placeholder implementation (simulate booking success)
    // Replace with real API when available.
    await Future.delayed(const Duration(milliseconds: 400));
  }
}
