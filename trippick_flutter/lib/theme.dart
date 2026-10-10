import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 색은 중립 회색 위주, 포인트 색은 [accent] 하나만 씁니다.
class AppColors {
  static const ink = Color(0xFF191F28);
  static const sub = Color(0xFF4E5968);
  static const faint = Color(0xFF8B95A1);
  static const line = Color(0xFFE5E8EB);
  static const soft = Color(0xFFF2F4F6);
  static const bg = Colors.white;

  static const accent = Color(0xFFF2552C);

  static const good = Color(0xFF1B7F5B);
  static const bad = Color(0xFFD1453B);
  static const tip = Color(0xFF946200);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      primary: AppColors.accent,
      surface: AppColors.bg,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    dividerColor: AppColors.line,
    dividerTheme: const DividerThemeData(color: AppColors.line, space: 1),
  );
  return base.copyWith(
    textTheme: GoogleFonts.notoSansKrTextTheme(base.textTheme).apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
  );
}

class AppText {
  static TextStyle get _f =>
      GoogleFonts.notoSansKr(color: AppColors.ink, height: 1.4);

  static TextStyle get title => _f.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );
  static TextStyle get section => _f.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );
  static TextStyle get name => _f.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );
  static TextStyle get body => _f.copyWith(fontSize: 14, color: AppColors.sub);
  static TextStyle get small =>
      _f.copyWith(fontSize: 13, color: AppColors.faint);
  static TextStyle get caption =>
      _f.copyWith(fontSize: 12, color: AppColors.faint);
}
