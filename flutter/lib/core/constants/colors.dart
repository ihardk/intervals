import 'package:flutter/material.dart';

/// Minimalist color system - Black, White, and Grey spectrum
/// Following the design philosophy: high contrast, minimalism, no color
class AppColors {
  // Primary Colors
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);

  // Grey Spectrum (from dark to light)
  static const grey1 = Color(0xFF1A1A1A);  // Darkest grey
  static const grey2 = Color(0xFF333333);
  static const grey3 = Color(0xFF666666);  // Medium grey
  static const grey4 = Color(0xFF999999);
  static const grey5 = Color(0xFFCCCCCC);
  static const grey6 = Color(0xFFE5E5E5);
  static const grey7 = Color(0xFFF5F5F5);  // Lightest grey

  // Semantic Colors (using grey spectrum)
  static const primary = black;
  static const secondary = grey3;
  static const background = white;
  static const surface = white;
  static const error = grey2;
  static const textPrimary = black;
  static const textSecondary = grey3;
  static const textHint = grey4;
  static const divider = grey6;
  static const disabled = grey5;

  // Category Colors (minimal color for data visualization only)
  static const categoryWork = Color(0xFF3B82F6);      // Blue
  static const categoryBreak = Color(0xFF10B981);     // Green
  static const categoryLearning = Color(0xFF8B5CF6); // Purple
  static const categorySocial = Color(0xFFF59E0B);    // Orange
  static const categoryDistraction = Color(0xFFEF4444); // Red

  // Private constructor to prevent instantiation
  AppColors._();
}
