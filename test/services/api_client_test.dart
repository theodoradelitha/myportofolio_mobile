import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

const _base = 'http://test.local';

http.Response _json(Object body, int status) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

/// An ApiClient whose every request is answered by [handler].
ApiClient _client(
  Future<http.Response> Function(http.Request request) handler,
) => ApiClient(client: MockClient(handler), baseUrl: _base);

void main() {
  late http.Request captured;

  Future<http.Response> Function(http.Request) respond(http.Response r) =>
      (request) async {
        captured = request;
        return r;
      };

  group('getProjects', () {
    test('GETs the public list without a token and parses it', () async {
      final api = _client(
        respond(
          _json([
            {
              'id': '1',
              'title': 'Café ☕',
              'description': 'd',
              'tech_stack': 'Dart',
              'demo_link': null,
              'image': '',
            },
          ], 200),
        ),
      );

      final projects = await api.getProjects();

      expect(captured.method, 'GET');
      expect(captured.url.toString(), '$_base/api/v1/projects/');
      expect(captured.headers['Accept'], 'application/json');
      expect(captured.headers.containsKey('Authorization'), isFalse);
      expect(projects.single.title, 'Café ☕');
    });

    test('a server error becomes an ApiException without the raw body', () {
      final api = _client(
        respond(http.Response('<html>Traceback</html>', 500)),
      );

      expect(
        api.getProjects(),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.message, 'message', isNot(contains('<html>'))),
        ),
      );
    });

    test('a connection failure becomes a network ApiException', () {
      final api = _client(
        (_) async => throw http.ClientException('Connection refused'),
      );

      expect(
        api.getProjects(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.isNetworkError,
            'isNetworkError',
            isTrue,
          ),
        ),
      );
    });

    // testWidgets runs in fake time, so 16 seconds pass instantly.
    testWidgets('a request that never answers times out', (tester) async {
      final api = _client((_) => Completer<http.Response>().future);

      final expectation = expectLater(
        api.getProjects(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.isNetworkError,
            'isNetworkError',
            isTrue,
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 16));
      await expectation;
    });
  });

  group('createProject', () {
    const project = Project(
      id: 'ignored',
      title: 'App',
      description: 'Mobile app',
      techStack: 'Flutter',
    );

    test('POSTs JSON with the token and returns the saved project', () async {
      final api = _client(
        respond(
          _json({
            ...project.toJson(),
            'id': 'new-id',
            'image': 'img/blank-folder.svg',
          }, 201),
        ),
      );

      final created = await api.createProject(project, token: 'abc123');

      expect(captured.method, 'POST');
      expect(captured.url.path, '/api/v1/projects/');
      expect(captured.headers['Authorization'], 'Token abc123');
      expect(captured.headers['Content-Type'], startsWith('application/json'));
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body.containsKey('id'), isFalse);
      expect(body['tech_stack'], 'Flutter');
      expect(created.id, 'new-id');
    });

    test('a 400 reports the first field error', () {
      final api = _client(
        respond(
          _json({
            'demo_link': ['Enter a valid URL.'],
          }, 400),
        ),
      );

      expect(
        api.createProject(project, token: 't'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having(
                (e) => e.message,
                'message',
                'Demo link: Enter a valid URL.',
              ),
        ),
      );
    });

    test('401 and 403 keep their status codes', () async {
      for (final status in [401, 403]) {
        final api = _client(respond(_json({'detail': 'No.'}, status)));
        await expectLater(
          api.createProject(project, token: 't'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', status)
                .having(
                  (e) => e.isUnauthorized,
                  'isUnauthorized',
                  status == 401,
                ),
          ),
        );
      }
    });
  });

  group('auth', () {
    test('obtainToken sends the credentials and returns the token', () async {
      final api = _client(respond(_json({'token': 'key-1'}, 200)));

      final token = await api.obtainToken('owner', 'p@ss word');

      expect(captured.url.path, '/api/v1/auth/token/');
      expect(jsonDecode(captured.body), {
        'username': 'owner',
        'password': 'p@ss word',
      });
      expect(captured.headers.containsKey('Authorization'), isFalse);
      expect(token, 'key-1');
    });

    test('wrong credentials surface as a 400', () {
      final api = _client(
        respond(
          _json({
            'non_field_errors': ['Unable to log in with provided credentials.'],
          }, 400),
        ),
      );

      expect(
        api.obtainToken('owner', 'wrong'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having(
                (e) => e.message,
                'message',
                'Unable to log in with provided credentials.',
              ),
        ),
      );
    });

    test('logout POSTs with the token and accepts 204', () async {
      final api = _client(respond(http.Response('', 204)));

      await api.logout(token: 'key-1');

      expect(captured.method, 'POST');
      expect(captured.url.path, '/api/v1/auth/logout/');
      expect(captured.headers['Authorization'], 'Token key-1');
    });
  });
}
