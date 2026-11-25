/// Base URL of the Django REST Framework backend, without a trailing slash.
///
/// Defaults to `http://10.0.2.2:8000`, the address of the host computer as
/// seen from inside the Android emulator. Override it per platform with
/// `--dart-define`, for example when running on Chrome:
///
/// ```sh
/// flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
/// ```
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);
