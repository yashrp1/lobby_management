import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/api_exception.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/performance_monitor.dart';
import '../../../data/repository/event_repository.dart';
import 'event_detail_state.dart';
import 'dart:async';

class EventDetailCubit extends Cubit<EventDetailState> {
  final EventRepository repository;
  Timer? _viewingTimer;
  Timer? _participantTimer;
  int _viewingCount = 0;

  EventDetailCubit({required this.repository}) : super(EventDetailInitial());

  Future<void> loadEventDetail(String eventId, String? token) async {
    AppLogger.info('Loading event detail: $eventId');
    PerformanceMonitor.startTimer('loadEventDetail');
    emit(EventDetailLoading());

    try {
      final event = await repository.getEventDetail(eventId, token);
      _viewingCount = _generateRandomViewingCount();
      
      emit(EventDetailLoaded(
        event: event,
        viewingCount: _viewingCount,
      ));

      PerformanceMonitor.endTimer('loadEventDetail');
      AppLogger.info('Event loaded successfully: ${event.lobby.title}');

      // Start timer for viewing count updates
      _startViewingTimer();
      _startParticipantTimer();
    } catch (e, stackTrace) {
      PerformanceMonitor.endTimer('loadEventDetail');
      final errorMessage = e is ApiException ? e.message : 'An error occurred';
      AppLogger.error('Failed to load event detail: $eventId', e, stackTrace);
      
      emit(EventDetailError(
        message: errorMessage,
      ));
    }
  }

  void _startViewingTimer() {
    _viewingTimer?.cancel();
    _viewingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (state is EventDetailLoaded) {
        _viewingCount = _generateRandomViewingCount();
        final currentState = state as EventDetailLoaded;
        emit(currentState.copyWith(viewingCount: _viewingCount));
      }
    });
  }

  void _startParticipantTimer() {
    _participantTimer?.cancel();
    _participantTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (state is EventDetailLoaded) {
        final currentState = state as EventDetailLoaded;
        final lobby = currentState.event.lobby;
        final delta = (DateTime.now().millisecondsSinceEpoch % 3) - 1; // -1, 0, or +1
        int next = lobby.currentMembers + delta;
        if (next < 0) next = 0;
        if (next > lobby.totalMembers) next = lobby.totalMembers;
        if (next != lobby.currentMembers) {
          final updatedLobby = lobby.copyWith(currentMembers: next);
          final updatedEvent = currentState.event.copyWith(lobby: updatedLobby);
          emit(currentState.copyWith(event: updatedEvent));
        }
      }
    });
  }

  int _generateRandomViewingCount() {
    return DateTime.now().millisecondsSinceEpoch % 50 + 1;
  }

  @override
  Future<void> close() {
    _viewingTimer?.cancel();
    _participantTimer?.cancel();
    return super.close();
  }
}
