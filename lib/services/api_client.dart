import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/project.dart';

/// Thrown when an API request fails, either with a non-2xx status code or
/// because the server could not be reached.
///
/// [message] is written for the user. Raw response bodies are never used as
/// the message, because with Django's DEBUG on they can be whole HTML error
/// pages with stack traces.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  /// Status code used when no response arrived at all.
  static const int noResponse = 0;

  final int statusCode;
  final String message;

  bool get isNetworkError => statusCode == noResponse;
  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// HTTP client for the MyPortfolio Django REST Framework backend.
///
/// All network calls go through this class, so screens only deal with
/// [Project] objects and [ApiException]s. The [http.Client] can be
/// replaced, which lets tests use `MockClient` instead of a real server.
///
/// Header names are plain strings instead of `dart:io`'s `HttpHeaders`,
/// because importing `dart:io` breaks Flutter Web builds.
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  static const Duration _timeout = Duration(seconds: 15);
  static const Map<String, String> _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
  };

  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _authHeader(String token) => {
    'Authorization': 'Token $token',
  };

  /// Lists every project. Public, so no token is sent.
  Future<List<Project>> getProjects() async {
    final response = await _send(
      () => _client.get(
        _uri('/api/v1/projects/'),
        headers: const {'Accept': 'application/json'},
      ),
    );
    final decoded = _decode(response) as List<dynamic>;
    return decoded
        .map((item) => Project.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Creates [project] on the server and returns the saved copy, which
  /// includes the id Django assigned.
  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final response = await _send(
      () => _client.post(
        _uri('/api/v1/projects/'),
        headers: {..._jsonHeaders, ..._authHeader(token)},
        body: jsonEncode(project.toJson()),
      ),
    );
    return Project.fromJson(_decode(response) as Map<String, dynamic>);
  }

  /// Exchanges a username and password for an auth token.
  ///
  /// DRF answers wrong credentials with 400, not 401.
  Future<String> obtainToken(String username, String password) async {
    final response = await _send(
      () => _client.post(
        _uri('/api/v1/auth/token/'),
        headers: _jsonHeaders,
        body: jsonEncode({'username': username, 'password': password}),
      ),
    );
    final decoded = _decode(response) as Map<String, dynamic>;
    return decoded['token'] as String;
  }

  /// Revokes [token] on the server. The server answers 204 No Content.
  Future<void> logout({required String token}) async {
    await _send(
      () => _client.post(
        _uri('/api/v1/auth/logout/'),
        headers: {'Accept': 'application/json', ..._authHeader(token)},
      ),
    );
  }

  /// Runs [request], turning connection failures and timeouts into
  /// [ApiException]s and rejecting non-2xx responses.
  Future<http.Response> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on http.ClientException {
      throw const ApiException(
        ApiException.noResponse,
        "Can't reach the server. Check that Django is running and the API "
        'address is correct.',
      );
    } on TimeoutException {
      throw const ApiException(
        ApiException.noResponse,
        'The server took too long to respond. Please try again.',
      );
    }
    _ensureSuccess(response);
    return response;
  }

  /// Decodes the body as UTF-8 JSON. `response.body` would fall back to
  /// Latin-1 if the server ever omitted the charset.
  Object? _decode(http.Response response) =>
      jsonDecode(utf8.decode(response.bodyBytes));

  void _ensureSuccess(http.Response response) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) return;
    throw ApiException(status, _messageFor(response));
  }

  String _messageFor(http.Response response) {
    switch (response.statusCode) {
      case 400:
        return _firstValidationError(response) ??
            'The server rejected the request. Please check your input.';
      case 401:
        return 'Your session has expired. Please log in again.';
      case 403:
        return "You don't have permission to do this.";
      case 404:
        return 'The requested item was not found.';
      case >= 500:
        return 'The server ran into an error. Please try again later.';
      default:
        return 'Request failed (HTTP ${response.statusCode}).';
    }
  }

  /// Reads the first message from a DRF validation error body such as
  /// `{"title": ["This field may not be blank."]}` or
  /// `{"non_field_errors": ["Unable to log in ..."]}`.
  String? _firstValidationError(http.Response response) {
    try {
      final decoded = _decode(response);
      if (decoded is! Map<String, dynamic>) return null;
      for (final entry in decoded.entries) {
        final value = entry.value;
        final message = value is List && value.isNotEmpty ? value.first : value;
        if (message is! String) continue;
        final isGeneral =
            entry.key == 'non_field_errors' || entry.key == 'detail';
        return isGeneral ? message : '${_label(entry.key)}: $message';
      }
    } on FormatException {
      // Not JSON (for example an HTML error page); use the generic message.
    }
    return null;
  }

  /// Turns a field name like "tech_stack" into "Tech stack".
  String _label(String field) {
    final words = field.replaceAll('_', ' ');
    return words.isEmpty ? words : words[0].toUpperCase() + words.substring(1);
  }
}
