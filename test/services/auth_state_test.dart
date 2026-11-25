import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

void main() {
  ApiClient apiAnswering(int Function(http.Request request) status) =>
      ApiClient(
        baseUrl: 'http://test.local',
        client: MockClient((request) async {
          final code = status(request);
          final body = request.url.path.endsWith('/auth/token/') && code == 200
              ? '{"token": "key-1"}'
              : '{}';
          return http.Response(body, code);
        }),
      );

  test('starts logged out unless given a token', () {
    final api = apiAnswering((_) => 200);
    expect(AuthState(api).isLoggedIn, isFalse);
    expect(AuthState(api, initialToken: 'x').isLoggedIn, isTrue);
  });

  test('login stores the token and notifies listeners', () async {
    final auth = AuthState(apiAnswering((_) => 200));
    var notified = 0;
    auth.addListener(() => notified++);

    await auth.login('owner', 'password');

    expect(auth.token, 'key-1');
    expect(auth.isLoggedIn, isTrue);
    expect(notified, 1);
  });

  test('a failed login throws and stays logged out', () async {
    final auth = AuthState(apiAnswering((_) => 400));
    var notified = 0;
    auth.addListener(() => notified++);

    await expectLater(
      auth.login('owner', 'wrong'),
      throwsA(isA<ApiException>()),
    );

    expect(auth.isLoggedIn, isFalse);
    expect(notified, 0);
  });

  test('logout revokes the token on the server and clears it', () async {
    final paths = <String>[];
    final auth = AuthState(
      apiAnswering((request) {
        paths.add(request.url.path);
        return 204;
      }),
      initialToken: 'key-1',
    );
    var notified = 0;
    auth.addListener(() => notified++);

    await auth.logout();

    expect(paths, ['/api/v1/auth/logout/']);
    expect(auth.isLoggedIn, isFalse);
    expect(notified, 1);
  });

  test('logout clears the session even when the server fails', () async {
    final auth = AuthState(apiAnswering((_) => 500), initialToken: 'key-1');

    await auth.logout();

    expect(auth.isLoggedIn, isFalse);
  });

  test('logout does nothing when already logged out', () async {
    var requests = 0;
    final auth = AuthState(
      apiAnswering((_) {
        requests++;
        return 204;
      }),
    );
    var notified = 0;
    auth.addListener(() => notified++);

    await auth.logout();

    expect(requests, 0);
    expect(notified, 0);
  });

  test('clearSession forgets the token without a request', () {
    var requests = 0;
    final auth = AuthState(
      apiAnswering((_) {
        requests++;
        return 204;
      }),
      initialToken: 'key-1',
    );

    auth.clearSession();

    expect(auth.isLoggedIn, isFalse);
    expect(requests, 0);
  });
}
