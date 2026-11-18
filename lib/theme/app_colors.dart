import 'package:material_ui/material_ui.dart';

/// Color palette of my portfolio website.
///
/// Names follow the CSS custom properties in the website's `style.css`
/// (for example [maroonMain] is `--maroon-main`), so both stay in sync.
abstract final class AppColors {
  // Cream tones
  static const Color bgCreamLight = Color(0xFFF8E8CE);
  static const Color cream = Color(0xFFFFF5E1);
  static const Color creamLight = Color(0xFFE4CEC2);
  static const Color creamDark = Color(0xFFDCC8A3);

  // Maroon tones
  static const Color maroonMain = Color(0xFF4E0911);
  static const Color maroonMuted = Color(0xFF905F66);
  static const Color vintageBurgundy = Color(0xFF9B1D30);
  static const Color maroonWineRed = Color(0xFFB0303C);

  /// Form error color used on the website.
  static const Color error = Color(0xFFB42318);

  /// Not part of the website palette. A muted olive that sits well next to
  /// the maroons, so every action card can have a clearly different color.
  static const Color olive = Color(0xFF4F5D2F);
}
