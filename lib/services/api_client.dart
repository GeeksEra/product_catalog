import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:product_catalog/config/api_config.dart';
import 'package:product_catalog/services/api_exception.dart';

/// A thin wrapper over [http.Client] for JSON GET requests.
///
/// It applies the base URL and timeout, checks the status code, decodes the
/// body, and turns every failure into an [ApiException].
class ApiClient {
  ApiClient({
    required http.Client client,
    String baseUrl = ApiConfig.baseUrl,
    Duration timeout = ApiConfig.timeout,
  }) : _client = client,
       _baseUri = Uri.parse(baseUrl),
       _timeout = timeout;

  final http.Client _client;
  final Uri _baseUri;
  final Duration _timeout;

  /// GETs [path] and returns the body, which must be a JSON object.
  Future<Map<String, dynamic>> getObject(
    String path, {
    Map<String, String>? query,
  }) async {
    final body = await _get(path, query);
    if (body is Map<String, dynamic>) return body;
    throw const ParseException();
  }

  /// GETs [path] and returns the body, which must be a JSON array.
  Future<List<dynamic>> getList(
    String path, {
    Map<String, String>? query,
  }) async {
    final body = await _get(path, query);
    if (body is List<dynamic>) return body;
    throw const ParseException();
  }

  Future<Object?> _get(String path, Map<String, String>? query) async {
    final uri = _baseUri.replace(
      path: path,
      queryParameters: query == null || query.isEmpty ? null : query,
    );

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw const NetworkException('The request timed out. Please try again.');
    } on http.ClientException {
      throw const NetworkException();
    }

    if (response.statusCode == 404) {
      throw const ServerException(404, 'That item could not be found.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ServerException(response.statusCode);
    }

    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const ParseException();
    }
  }
}
