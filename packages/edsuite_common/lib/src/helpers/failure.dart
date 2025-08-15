enum FailureType {
  timeout,
  notFound,
  badRequest,
  unauthorized,
  forbidden,
  conflict,
  requestEntityTooLarge,
  internalServerError,
  serviceUnavailable,
  internetConnection,
  unhandled,
  localizationError,
  notResults,
  sessionExpired,
  rateLimitExceeded,
  serverNotAvailable,
}

class Failure implements Exception {
  Failure({this.message, this.code, this.statusCode = 0})
    : failureType = FailureTypeHelper.getFailureType(statusCode, code);
  final String? message;
  final String? code;
  final int? statusCode;
  final FailureType failureType;
}

class FailureTypeHelper {
  static FailureType getFailureType(int? statusCode, [String? code]) {
    // Primero verificar códigos de aplicación específicos
    if (code != null) {
      switch (code.toUpperCase()) {
        case 'SESSION_EXPIRED':
          return FailureType.sessionExpired;
        case 'RATE_LIMIT_EXCEEDED':
          return FailureType.rateLimitExceeded;
      }
    }

    if (statusCode == -1) {
      return FailureType.internetConnection;
    }

    if (statusCode == -2) {
      return FailureType.localizationError;
    }

    if (statusCode == -3) {
      return FailureType.serverNotAvailable;
    }

    switch (statusCode) {
      case 400:
        return FailureType.badRequest;
      case 401:
        return FailureType.unauthorized;
      case 403:
        return FailureType.forbidden;
      case 404:
        return FailureType.notFound;
      case 408:
        return FailureType.timeout;
      case 409:
        return FailureType.conflict;
      case 413:
        return FailureType.requestEntityTooLarge;
      case 500:
        return FailureType.internalServerError;
      case 503:
        return FailureType.serviceUnavailable;
      default:
        return FailureType.unhandled;
    }
  }
}
