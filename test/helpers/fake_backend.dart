import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

/// An in-memory stand-in for the Django API, used through `MockClient`.
///
/// It follows the real backend's rules: the project list is public, wrong
/// credentials give 400, writes without a valid token give 401, a valid
/// token of a non-owner gives 403, and logout deletes the token (204).
class FakeBackend {
  FakeBackend({List<Map<String, dynamic>>? projects})
    : projects = [...(projects ?? defaultProjects)];

  static const String baseUrl = 'http://test.local';
  static const String ownerUsername = 'owner';
  static const String visitorUsername = 'visitor';
  static const String password = 'correct-password';

  static const List<Map<String, dynamic>> defaultProjects = [
    {
      'id': '11111111-1111-1111-1111-111111111111',
      'title': 'OH26',
      'description': 'Recruitment landing page for OH 2026.',
      'tech_stack': 'Next.js, TypeScript, Tailwind CSS',
      'demo_link': 'https://example.com/oh26',
      'image': 'img/oh-project.webp',
      'star_count': 2,
      'is_starred': false,
      'starred_by_names': 'a, b',
    },
    {
      'id': '22222222-2222-2222-2222-222222222222',
      'title': 'Symbiocle',
      'description': 'Circular economy dashboard.',
      'tech_stack': 'Next.js 14, Python FastAPI',
      'demo_link': null,
      'image': 'img/blank-folder.svg',
      'star_count': 0,
      'is_starred': false,
      'starred_by_names': '',
    },
  ];

  final List<Map<String, dynamic>> projects;

  /// Valid tokens, mapped to the username they belong to.
  final Map<String, String> tokens = {};

  /// Every request the app sent, in order.
  final List<http.Request> requests = [];

  /// When set, the project list answers with this status and an HTML body,
  /// like Django's debug error page.
  int? failProjectListWith;

  /// When set, project list requests wait until it is completed.
  Completer<void>? holdProjectList;

  int _nextId = 1;

  late final ApiClient apiClient = ApiClient(
    client: MockClient(_handle),
    baseUrl: baseUrl,
  );

  int get projectListRequests => requests
      .where((r) => r.method == 'GET' && r.url.path == '/api/v1/projects/')
      .length;

  /// Revokes every token, as if the user logged out on another device.
  void revokeAllTokens() => tokens.clear();

  Future<http.Response> _handle(http.Request request) async {
    requests.add(request);
    final route = '${request.method} ${request.url.path}';

    switch (route) {
      case 'GET /api/v1/projects/':
        await holdProjectList?.future;
        final status = failProjectListWith;
        if (status != null) {
          return http.Response('<html>Traceback: secret</html>', status);
        }
        return _json(projects, 200);
      case 'POST /api/v1/auth/token/':
        return _obtainToken(request);
      case 'POST /api/v1/projects/':
        return _createProject(request);
      case 'POST /api/v1/auth/logout/':
        final token = _tokenOf(request);
        if (token == null) return _json({'detail': 'Invalid token.'}, 401);
        tokens.remove(token);
        return http.Response('', 204);
    }
    return _json({'detail': 'Not found.'}, 404);
  }

  http.Response _obtainToken(http.Request request) {
    final body = jsonDecode(request.body) as Map<String, dynamic>;
    final username = body['username'];
    final known = username == ownerUsername || username == visitorUsername;
    if (!known || body['password'] != password) {
      return _json({
        'non_field_errors': ['Unable to log in with provided credentials.'],
      }, 400);
    }
    final token = 'token-${_nextId++}';
    tokens[token] = username as String;
    return _json({'token': token}, 200);
  }

  http.Response _createProject(http.Request request) {
    final token = _tokenOf(request);
    if (token == null) return _json({'detail': 'Invalid token.'}, 401);
    if (tokens[token] != ownerUsername) {
      return _json({
        'detail': 'Only the portfolio owner can change projects.',
      }, 403);
    }

    final body = jsonDecode(request.body) as Map<String, dynamic>;
    if ((body['title'] as String? ?? '').trim().isEmpty) {
      return _json({
        'title': ['This field may not be blank.'],
      }, 400);
    }
    final image = body['image'] as String? ?? '';
    final created = {
      ...body,
      'id': 'created-${_nextId++}',
      'image': image.isEmpty ? 'img/blank-folder.svg' : image,
      'star_count': 0,
      'is_starred': false,
      'starred_by_names': '',
    };
    projects.add(created);
    return _json(created, 201);
  }

  /// The token from a valid `Authorization: Token <key>` header, if any.
  String? _tokenOf(http.Request request) {
    final header = request.headers['Authorization'] ?? '';
    if (!header.startsWith('Token ')) return null;
    final token = header.substring('Token '.length);
    return tokens.containsKey(token) ? token : null;
  }

  http.Response _json(Object body, int status) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}
