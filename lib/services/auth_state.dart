import 'package:flutter/foundation.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

/// Holds the auth token for the current session, in memory only.
///
/// Widgets that call `context.watch<AuthState>()` rebuild whenever
/// [notifyListeners] runs, so the drawer and other UI switch between
/// "Login" and "Logout" automatically. Closing the app forgets the token.
class AuthState extends ChangeNotifier {
  AuthState(this._apiClient, {String? initialToken}) : _token = initialToken;

  final ApiClient _apiClient;
  String? _token;

  String? get token => _token;
  bool get isLoggedIn => _token != null;

  /// Logs in, or throws [ApiException] and stays logged out.
  Future<void> login(String username, String password) async {
    _token = await _apiClient.obtainToken(username, password);
    notifyListeners();
  }

  /// Revokes the token on the server and forgets it locally.
  ///
  /// The local session is cleared even when the request fails (for example
  /// when the server is offline), so the user is never stuck logged in.
  Future<void> logout() async {
    final current = _token;
    if (current == null) return;

    try {
      await _apiClient.logout(token: current);
    } on ApiException catch (error) {
      // The token is forgotten below either way. If the server couldn't
      // revoke it, it stops being used by this app regardless.
      debugPrint('Server logout failed with status ${error.statusCode}.');
    } finally {
      _token = null;
      notifyListeners();
    }
  }

  /// Forgets the token without calling the server. Used after the server
  /// answered 401, which means it no longer accepts the token anyway.
  void clearSession() {
    if (_token == null) return;
    _token = null;
    notifyListeners();
  }
}
