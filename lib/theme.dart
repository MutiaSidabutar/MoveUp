import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Tema monokrom terinspirasi foto hitam-putih: langit berkabut, aspal, dan siluet atlet.
class _Palette {
  const _Palette({
    required this.background,
    required this.surface,
    required this.border,
    required this.text,
    required this.muted,
    required this.input,
  });

  final Color background;
  final Color surface;
  final Color border;
  final Color text;
  final Color muted;
  final Color input;
}

// Skala jarak dipakai di semua layar supaya ritme tata letak seragam
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 32.0;

  // Padding tepi layar
  static const page = EdgeInsets.all(xl);
}

// Satu bentuk sudut untuk tombol, field, dan kartu
class AppRadius {
  static const control = 10.0;
  static const card = 12.0;
  static const sheet = 20.0;
}

class AppTheme {
  // Warna status; sengaja sedikit redup agar tetap serasi dengan tema monokrom
  static const danger = Color(0xFFD64545);
  static const success = Color(0xFF3F9A5C);
  static const warning = Color(0xFFE09A2B);

  // Terang: kabut pagi
  static const _fog = _Palette(
    background: Color(0xFFE9E9E6),
    surface: Color(0xFFF4F4F1),
    border: Color(0xFFD4D4D0),
    text: Color(0xFF121212),
    muted: Color(0xFF6E6E6A),
    input: Color(0xFFDEDEDA),
  );

  // Gelap: aspal basah
  static const _asphalt = _Palette(
    background: Color(0xFF0D0D0D),
    surface: Color(0xFF181818),
    border: Color(0xFF2A2A2A),
    text: Color(0xFFECECE8),
    muted: Color(0xFF8A8A86),
    input: Color(0xFF222222),
  );

  static ThemeData get lightTheme => _build(Brightness.light, _fog);

  static ThemeData get darkTheme => _build(Brightness.dark, _asphalt);

  // Huruf condensed tebal untuk judul dan angka statistik, seperti poster olahraga
  static TextStyle display(double size, {Color? color, double letterSpacing = 0.5}) => GoogleFonts.barlowCondensed(
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: letterSpacing,
        color: color,
      );

  static ThemeData _build(Brightness brightness, _Palette p) {
    // Warna utama sama dengan warna teks: hitam di tema terang, putih kabut di tema gelap
    final primary = p.text;
    final onPrimary = p.surface;
    final base = brightness == Brightness.light ? ThemeData.light() : ThemeData.dark();
    final body = GoogleFonts.interTextTheme(base.textTheme).apply(bodyColor: p.text, displayColor: p.text);
    final condensed = GoogleFonts.barlowCondensedTextTheme(base.textTheme).apply(bodyColor: p.text, displayColor: p.text);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: p.muted,
      onSecondary: onPrimary,
      // Dipakai Material 3 untuk chip yang dipilih
      secondaryContainer: primary,
      onSecondaryContainer: onPrimary,
      error: danger,
      onError: Colors.white,
      surface: p.surface,
      onSurface: p.text,
      onSurfaceVariant: p.muted,
      outline: p.border,
      outlineVariant: p.border,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      primaryColor: primary,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      dividerColor: p.border,
      textTheme: body.copyWith(
        displayLarge: condensed.displayLarge,
        displayMedium: condensed.displayMedium,
        displaySmall: condensed.displaySmall,
        headlineLarge: condensed.headlineLarge,
        headlineMedium: condensed.headlineMedium,
        headlineSmall: condensed.headlineSmall,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: p.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: display(22, color: p.text, letterSpacing: 1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          textStyle: const TextStyle(letterSpacing: 1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: primary)),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        filled: true,
        fillColor: p.input,
        labelStyle: TextStyle(color: p.muted),
        floatingLabelStyle: TextStyle(color: p.text, fontWeight: FontWeight.w600),
        errorMaxLines: 2,
        hintStyle: TextStyle(color: p.muted),
        prefixIconColor: p.muted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: p.border, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        side: BorderSide(color: p.border),
        checkmarkColor: onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
          side: BorderSide(color: p.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sheet)),
        titleTextStyle: display(24, color: p.text),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.text,
        contentTextStyle: TextStyle(color: p.surface),
        actionTextColor: p.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
      ),
      popupMenuTheme: PopupMenuThemeData(color: p.surface),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? onPrimary : p.muted),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? primary : p.input),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.surface,
        selectedItemColor: primary,
        unselectedItemColor: p.muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
