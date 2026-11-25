import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_page.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

/// The login screen currently open on each navigator, if any. An Expando
/// attaches the value to the navigator itself, so it goes away with it.
final Expando<Future<bool>> _pendingLogins = Expando('pendingLogin');

/// Makes sure the user is logged in before a protected action.
///
/// Returns true right away when there is already a token. Otherwise opens
/// [LoginPage] and returns whether the user logged in there. If a login
/// screen is already open (for example after a double tap), the same result
/// is shared instead of stacking a second one.
///
/// Call it while [context] is still mounted, before any other `await`.
Future<bool> ensureLoggedIn(BuildContext context) {
  if (context.read<AuthState>().isLoggedIn) return Future.value(true);

  final navigator = Navigator.of(context);
  final pending = _pendingLogins[navigator];
  if (pending != null) return pending;

  final login = navigator
      .push<bool>(MaterialPageRoute(builder: (_) => const LoginPage()))
      .then((loggedIn) => loggedIn ?? false)
      .whenComplete(() => _pendingLogins[navigator] = null);
  _pendingLogins[navigator] = login;
  return login;
}
