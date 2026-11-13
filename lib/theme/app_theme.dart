import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/theme/app_colors.dart';

/// App-wide theme that mirrors the look of my portfolio website.
abstract final class AppTheme {
  static const String bodyFont = 'TT Chocolates';
  static const String headingFont = 'Butler';
  static const String displayFont = 'Genty';

  static const double _buttonRadius = 8.0;
  static const double _cardRadius = 20.0;

  static final ThemeData light = _buildLightTheme();

  static ThemeData _buildLightTheme() {
    final colorScheme = ColorScheme.fromSeed(seedColor: AppColors.maroonMain)
        .copyWith(
          primary: AppColors.maroonMain,
          onPrimary: AppColors.cream,
          secondary: AppColors.maroonMuted,
          onSecondary: AppColors.cream,
          tertiary: AppColors.vintageBurgundy,
          onTertiary: AppColors.cream,
          error: AppColors.error,
          surface: AppColors.cream,
          onSurface: AppColors.maroonMain,
          onSurfaceVariant: AppColors.maroonMuted,
          outline: AppColors.creamDark,
          outlineVariant: AppColors.creamDark,
        );

    final textTheme = _buildTextTheme();
    const buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(_buttonRadius)),
    );

    OutlineInputBorder inputBorder(Color color, {double width = 1.0}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.bgCreamLight,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.maroonMain,
        foregroundColor: AppColors.cream,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.cream,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 3.0,
        shadowColor: Color(0x40000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_cardRadius)),
        ),
      ),
      chipTheme: ChipThemeData(
        labelStyle: textTheme.labelLarge?.copyWith(color: AppColors.maroonMain),
        side: const BorderSide(color: AppColors.maroonMain, width: 2.0),
        shape: buttonShape,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.maroonMain,
          foregroundColor: AppColors.cream,
          shape: buttonShape,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.maroonMain,
          shape: buttonShape,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.maroonMain,
        foregroundColor: AppColors.cream,
        shape: StadiumBorder(),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: AppColors.cream,
        labelStyle: const TextStyle(color: AppColors.maroonMuted),
        floatingLabelStyle: const TextStyle(color: AppColors.vintageBurgundy),
        border: inputBorder(AppColors.vintageBurgundy),
        enabledBorder: inputBorder(AppColors.vintageBurgundy),
        focusedBorder: inputBorder(AppColors.vintageBurgundy, width: 2.0),
        errorBorder: inputBorder(AppColors.error),
        focusedErrorBorder: inputBorder(AppColors.error, width: 2.0),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.cream,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.maroonMain,
        ),
        elevation: 6.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
          side: const BorderSide(color: AppColors.creamDark),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontFamily: bodyFont,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: AppColors.maroonMuted,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.maroonMain,
        textColor: AppColors.maroonMain,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.creamDark),
    );
  }

  /// TT Chocolates for body text, Butler for headings (like the website's
  /// h1-h3) and Genty for large display titles such as project names.
  static TextTheme _buildTextTheme() {
    final base = Typography.material2021().black.apply(
      fontFamily: bodyFont,
      bodyColor: AppColors.maroonMain,
      displayColor: AppColors.maroonMain,
    );

    TextStyle? heading(TextStyle? style) =>
        style?.copyWith(fontFamily: headingFont, fontWeight: FontWeight.w600);
    TextStyle? display(TextStyle? style) =>
        style?.copyWith(fontFamily: displayFont, height: 1.1);

    return base.copyWith(
      displayLarge: display(base.displayLarge),
      displayMedium: display(base.displayMedium),
      displaySmall: display(base.displaySmall),
      headlineLarge: heading(base.headlineLarge),
      headlineMedium: heading(base.headlineMedium),
      headlineSmall: heading(base.headlineSmall),
      titleLarge: heading(base.titleLarge),
      // Small uppercase "kicker" labels, like `.section-kicker` on the site.
      labelSmall: base.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      ),
    );
  }
}
