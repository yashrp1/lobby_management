import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../services/connectivity_service.dart';
import '../screens/no_internet_screen.dart';

class ConnectivityGate extends StatefulWidget {
  final Widget child;

  const ConnectivityGate({
    super.key,
    required this.child,
  });

  @override
  State<ConnectivityGate> createState() => _ConnectivityGateState();
}

class _ConnectivityGateState extends State<ConnectivityGate> {
  late final ConnectivityService _connectivityService;
  StreamSubscription<ConnectivityResult>? _subscription;
  ConnectivityResult? _current;

  @override
  void initState() {
    super.initState();
    _connectivityService = getIt.get<ConnectivityService>();
    _checkNow();
    _subscription = _connectivityService.onConnectivityChanged.listen((event) {
      if (!mounted) return;
      setState(() => _current = event);
    });
  }

  Future<void> _checkNow() async {
    final status = await _connectivityService.check();
    if (!mounted) return;
    setState(() => _current = status);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  bool get _isOffline => _current == ConnectivityResult.none;

  @override
  Widget build(BuildContext context) {
    if (_current == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_isOffline) {
      return NoInternetScreen(onRetry: _checkNow);
    }
    return widget.child;
  }
}


