import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../services/connectivity_service.dart';
import '../screens/no_internet_screen.dart';
import '../../services/booking_queue_service.dart';
import '../../data/repository/event_repository.dart';

class ConnectivityGate extends StatefulWidget {
  final Widget child;
  final Future<bool> Function()? hasLocalData;

  const ConnectivityGate({
    super.key,
    required this.child,
    this.hasLocalData,
  });

  @override
  State<ConnectivityGate> createState() => _ConnectivityGateState();
}

class _ConnectivityGateState extends State<ConnectivityGate> {
  late final ConnectivityService _connectivityService;
  late final BookingQueueService _bookingQueueService;
  late final EventRepository _repository;
  StreamSubscription<ConnectivityResult>? _subscription;
  ConnectivityResult? _current;
  bool? _hasLocal;

  @override
  void initState() {
    super.initState();
    _connectivityService = getIt.get<ConnectivityService>();
    _bookingQueueService = getIt.get<BookingQueueService>();
    _repository = getIt.get<EventRepository>();
    _checkNow();
    _subscription = _connectivityService.onConnectivityChanged.listen((event) {
      if (!mounted) return;
      final wasOffline = _current == ConnectivityResult.none;
      setState(() => _current = event);
      if (wasOffline && event != ConnectivityResult.none) {
        _processQueuedBookings();
      }
      if (event == ConnectivityResult.none) {
        _evaluateLocal();
      }
    });
  }

  Future<void> _processQueuedBookings() async {
    final items = _bookingQueueService.getAll();
    for (final entry in items) {
      final payload = entry.value;
      try {
        await _repository.bookTicket(
          eventId: payload['eventId'] as String,
          ticketId: payload['ticketId'] as String,
          quantity: (payload['quantity'] as num).toInt(),
          token: payload['token'] as String?,
        );
        await _bookingQueueService.remove(entry.key);
      } catch (_) {
        // stop processing on first failure; will retry next connectivity change
        break;
      }
    }
  }

  Future<void> _checkNow() async {
    final status = await _connectivityService.check();
    if (!mounted) return;
    setState(() => _current = status);
    if (status == ConnectivityResult.none) {
      _evaluateLocal();
    }
  }

  Future<void> _evaluateLocal() async {
    if (widget.hasLocalData == null) {
      setState(() => _hasLocal = null);
      return;
    }
    try {
      final ok = await widget.hasLocalData!.call();
      if (mounted) setState(() => _hasLocal = ok);
    } catch (_) {
      if (mounted) setState(() => _hasLocal = false);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // bool get _isOffline => _current == ConnectivityResult.none;

  @override
  Widget build(BuildContext context) {
    if (_current == ConnectivityResult.none && _hasLocal == false) {
      return NoInternetScreen(onRetry: _checkNow);
    }
    return widget.child;
  }
}


