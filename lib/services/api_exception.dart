/// Failures from the API layer. Each [message] is safe to show to the user.
sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// No connection, or the request timed out.
final class NetworkException extends ApiException {
  const NetworkException([
    super.message = 'Could not reach the server. Check your connection.',
  ]);
}

/// The server answered with a non-2xx status code.
final class ServerException extends ApiException {
  const ServerException(this.statusCode, [String? message])
    : super(message ?? 'The server returned an error ($statusCode).');

  final int statusCode;
}

/// The response body was not the JSON shape the app expects.
final class ParseException extends ApiException {
  const ParseException([
    super.message = 'The server sent data the app could not read.',
  ]);
}
