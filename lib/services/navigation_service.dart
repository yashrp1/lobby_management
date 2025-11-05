import 'package:flutter/material.dart';

/// Simple navigation service abstraction for future use/testing
abstract class NavigationService {
  Future<T?> push<T>(BuildContext context, Route<T> route);
  void pop<T extends Object?>(BuildContext context, [T? result]);
}

class NavigationServiceImpl implements NavigationService {
  @override
  Future<T?> push<T>(BuildContext context, Route<T> route) {
    return Navigator.of(context).push(route);
  }

  @override
  void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.of(context).pop(result);
  }
}


