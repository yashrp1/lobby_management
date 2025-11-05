import 'package:flutter/material.dart';

/// Responsive breakpoints following Material Design 3
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 840;
  static const double desktop = 1200;
}

/// Responsive utilities for Material Design 3
class Responsive {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < Breakpoints.mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= Breakpoints.mobile && width < Breakpoints.desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= Breakpoints.desktop;
  }

  /// Get responsive width - returns max width for content on tablets/desktop
  static double getContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= Breakpoints.desktop) {
      return 1200;
    } else if (width >= Breakpoints.tablet) {
      return width * 0.8;
    }
    return width;
  }

  /// Get responsive padding based on screen size
  static double getScreenPadding(BuildContext context) {
    if (isTablet(context)) {
      return 32.0;
    } else if (isDesktop(context)) {
      return 48.0;
    }
    return 20.0;
  }

  /// Get responsive column count for grid layouts
  static int getColumnCount(BuildContext context) {
    if (isDesktop(context)) {
      return 3;
    } else if (isTablet(context)) {
      return 2;
    }
    return 1;
  }

  /// Get responsive font size multiplier
  static double getFontScale(BuildContext context) {
    if (isTablet(context)) {
      return 1.1;
    } else if (isDesktop(context)) {
      return 1.2;
    }
    return 1.0;
  }
}

