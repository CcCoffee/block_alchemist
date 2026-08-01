import 'package:flutter/material.dart';

/// 方块炼金师主题色
class AppColors {
  // 品牌
  static const Color primary = Color(0xFF6EA8FF);
  static const Color accent = Color(0xFF7C5CFF);
  static const Color gold = Color(0xFFFFD34D);
  static const Color danger = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF7BED9F);

  // 深色背景
  static const Color darkBg = Color(0xFF0A0D18);
  static const Color darkCard = Color(0xFF161D33);
  static const Color darkBorder = Color(0xFF2A3552);
  static const Color darkTextPrimary = Color(0xFFEEF2FF);
  static const Color darkTextSecondary = Color(0xFF8A93B5);

  // 稀有度颜色
  static const List<Color> rarityColors = <Color>[
    Color(0xFF8B95A5),
    Color(0xFFC8D3E0),
    Color(0xFF4DA3FF),
    Color(0xFFB06BFF),
    Color(0xFFFFB62E),
  ];
}

/// 应用主题（深色炼金实验室风格）
class AppTheme {
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: AppColors.darkBg,
      cardColor: AppColors.darkCard,
      dividerColor: AppColors.darkBorder,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkCard,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
        bodyMedium: TextStyle(color: AppColors.darkTextPrimary),
        bodySmall: TextStyle(color: AppColors.darkTextSecondary),
        titleLarge: TextStyle(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.darkTextSecondary),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}
