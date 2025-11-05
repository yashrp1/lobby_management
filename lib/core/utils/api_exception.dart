class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException({super.message = 'No internet connection'});
}

class ServerException extends ApiException {
  const ServerException({
    super.message = 'Server error',
    super.statusCode,
  });
}

class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Resource not found',
    super.statusCode = 404,
  });
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Unauthorized',
    super.statusCode = 401,
  });
}
