import 'validators.dart';

/// Form validation utilities following Flutter best practices
class FormValidators {
  /// Required field validator
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Email validator
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!Validators.isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Phone number validator
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Remove spaces, dashes, and parentheses
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Length validator
  static String? length(String? value, {int? min, int? max, String? fieldName}) {
    if (value == null) return null;
    
    if (min != null && value.length < min) {
      return '${fieldName ?? 'Field'} must be at least $min characters';
    }
    if (max != null && value.length > max) {
      return '${fieldName ?? 'Field'} must be at most $max characters';
    }
    return null;
  }

  /// Number range validator
  static String? numberRange(num? value, {num? min, num? max, String? fieldName}) {
    if (value == null) return null;
    
    if (min != null && value < min) {
      return '${fieldName ?? 'Value'} must be at least $min';
    }
    if (max != null && value > max) {
      return '${fieldName ?? 'Value'} must be at most $max';
    }
    return null;
  }

  /// URL validator
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    if (!Validators.isValidUrl(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  /// Sanitize and validate input
  static String? sanitizeAndValidate(String? value, String? Function(String?) validator) {
    if (value == null) return validator(value);
    final sanitized = Validators.sanitizeInput(value);
    return validator(sanitized);
  }
}
