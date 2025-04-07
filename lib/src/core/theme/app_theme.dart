import 'package:dribbble_challenge/src/core/theme/app_colors.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

final mainTheme = FlexThemeData.light(
  colors: const FlexSchemeColor(
    primary: Color(0xFFFC6011), // AppColors.primary
    primaryContainer: Color(0xFFFFD8C2),
    secondary: Color(0xFFFFC107), // AppColors.onBoardingButtonColor
    secondaryContainer: Color(0xFFFFECB3),
    appBarColor: Color(0xFFFC6011),
    error: Colors.redAccent,
  ),
  surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,
  blendLevel: 8,
  appBarStyle: FlexAppBarStyle.primary,
  appBarOpacity: 0.95,
  subThemesData: const FlexSubThemesData(
    blendOnLevel: 10,
    blendTextTheme: true,
    defaultRadius: 12,
    elevatedButtonRadius: 16,
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  useMaterial3: true,
).copyWith(
  scaffoldBackgroundColor: AppColors.white,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: Color(0xFF4A4B4D), // AppColors.primaryText
      height: 1.5,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 15,
      color: Color(0xFF4A4B4D),
    ),
    bodySmall: TextStyle(fontSize: 14, color: Color(0xFF7C7D7E)), // secondaryText
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4A4B4D)),
    titleMedium: TextStyle(
      color: Color(0xFF4A4B4D),
      height: 1.4,
      fontSize: 17,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: Color(0xFF4A4B4D),
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      color: Color(0xFFFC6011), // Destaque com laranja
      fontWeight: FontWeight.bold,
    ),
    labelMedium: TextStyle(fontSize: 12, color: Color(0xFFFFC107)),
    labelLarge: TextStyle(
      fontSize: 12,
      color: Color(0xFF7C7D7E),
      fontWeight: FontWeight.w400,
    ),
  ),
  cardTheme: CardTheme(
    color: AppColors.textfield,
    elevation: 2,
    margin: const EdgeInsets.fromLTRB(10, 15, 10, 0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
);
