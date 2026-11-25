/// Validation rules shared by the portfolio forms.
///
/// Every method has the shape that `TextFormField.validator` expects: it
/// returns an error message when the value is invalid, or null when it is
/// fine. The Form shows the message under the field that returned it.
abstract final class Validators {
  /// Rejects empty and whitespace-only values, and values longer than
  /// [maxLength] once the surrounding spaces are trimmed.
  ///
  /// [fieldName] starts the error message, for example "Role cannot be
  /// empty."
  static String? requiredText(
    String? value, {
    required String fieldName,
    int? maxLength,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$fieldName cannot be empty.';
    if (maxLength != null && text.length > maxLength) {
      return '$fieldName must be at most $maxLength characters.';
    }
    return null;
  }

  /// Allows an empty value, but a filled-in value must be a full web address
  /// such as `https://example.com`.
  ///
  /// `Uri.tryParse` accepts almost any text (`example.com` parses as a path),
  /// so the scheme and host are checked explicitly.
  static String? optionalWebUrl(String? value) {
    final link = value?.trim() ?? '';
    if (link.isEmpty) return null;

    final uri = Uri.tryParse(link);
    final isWebUrl =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!isWebUrl) return 'Enter a full link starting with http:// or https://';
    return null;
  }
}
