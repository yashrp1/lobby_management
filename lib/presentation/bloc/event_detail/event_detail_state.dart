import 'package:equatable/equatable.dart';
import '../../../data/models/event_detail_model.dart';

abstract class EventDetailState extends Equatable {
  const EventDetailState();

  @override
  List<Object?> get props => [];
}

class EventDetailInitial extends EventDetailState {}

class EventDetailLoading extends EventDetailState {}

class EventDetailLoaded extends EventDetailState {
  final EventDetailModel event;
  final int viewingCount;

  const EventDetailLoaded({
    required this.event,
    this.viewingCount = 0,
  });

  @override
  List<Object?> get props => [event, viewingCount];

  EventDetailLoaded copyWith({
    EventDetailModel? event,
    int? viewingCount,
  }) {
    return EventDetailLoaded(
      event: event ?? this.event,
      viewingCount: viewingCount ?? this.viewingCount,
    );
  }
}

class EventDetailError extends EventDetailState {
  final String message;

  const EventDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
