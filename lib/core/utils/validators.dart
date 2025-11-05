/// Input validation utilities
class Validators {
  /// Validate event ID format
  static bool isValidEventId(String? eventId) {
    if (eventId == null || eventId.isEmpty) return false;
    // MongoDB ObjectId format: 24 hex characters
    return RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(eventId);
  }

  /// Validate email format
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  /// Validate URL format
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sanitize string input (remove dangerous characters, XSS prevention)
  static String sanitizeInput(String? input) {
    if (input == null) return '';
    // Remove null bytes, control characters, and potentially dangerous HTML/script tags
    return input
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') // Control characters
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false), '') // Script tags
        .replaceAll(RegExp(r'<iframe[^>]*>.*?</iframe>', caseSensitive: false), '') // Iframe tags
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '') // JavaScript protocol
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '') // Event handlers
        .trim();
  }

  /// Validate token format (basic check)
  static bool isValidToken(String? token) {
    if (token == null || token.isEmpty) return false;
    // Basic validation: should not contain spaces and have minimum length
    return token.length >= 10 && !token.contains(' ');
  }

  /// Validate coordinates
  static bool isValidCoordinates(double? lat, double? lon) {
    if (lat == null || lon == null) return false;
    return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
  }
}

