import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp(apiClient: ApiClient()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.apiClient});

  /// Created once in [main] (or by a test with a mock HTTP client) and
  /// shared by every screen.
  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    // MultiProvider puts these objects above MaterialApp, so every screen,
    // including ones pushed later, can read them with context.read/watch.
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider<AuthState>(create: (_) => AuthState(apiClient)),
      ],
      child: MaterialApp(
        title: 'MyPortfolio',
        theme: AppTheme.light,
        home: const MyHomePage(),
      ),
    );
  }
}
