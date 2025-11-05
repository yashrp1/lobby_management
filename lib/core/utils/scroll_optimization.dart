import 'package:flutter/material.dart';

/// Scroll optimization utilities for 60fps performance
class ScrollOptimization {
  /// Get optimized scroll physics for smooth scrolling
  static const ScrollPhysics optimizedPhysics = BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
  );

  /// Wrap widget with RepaintBoundary for scroll optimization
  static Widget withRepaintBoundary(Widget child) {
    return RepaintBoundary(child: child);
  }

  /// Create optimized list view builder
  static Widget optimizedListView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollController? controller,
    EdgeInsets? padding,
  }) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      physics: optimizedPhysics,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

