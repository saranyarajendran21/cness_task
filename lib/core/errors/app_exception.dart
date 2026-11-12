import '../constants/app_strings.dart';

/// Base exception for all application-level and API errors.
sealed class AppException implements Exception {
  const AppException(this.message, {this.statusCode, this.details});

  final String message;
  final int? statusCode;
  final dynamic details;

  @override
  String toString() => message;
}

/// Thrown when the device has no active network connection.
class NoInternetException extends AppException {
  const NoInternetException([super.message = AppStrings.noInternet]);
}

/// Thrown when an API request exceeds the configured timeout.
class RequestTimeoutException extends AppException {
  const RequestTimeoutException([super.message = AppStrings.requestTimeout]);
}

/// Thrown when authentication is missing or expired (HTTP 401/403).
class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = AppStrings.sessionExpiredUnauthorized,
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

/// Thrown when the server returns a validation or client error (HTTP 400/422).
class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.statusCode,
    super.details,
  });
}

/// Thrown when the server returns a 5xx or unexpected API error response.
class ServerException extends AppException {
  const ServerException(
    super.message, {
    super.statusCode,
    super.details,
  });
}

/// Thrown when JSON response decoding or model mapping fails.
class ParseException extends AppException {
  const ParseException([super.message = AppStrings.parseError]);
}

/// Fallback exception for unexpected errors.
class UnknownException extends AppException {
  const UnknownException([super.message = AppStrings.unknownError]);
}
