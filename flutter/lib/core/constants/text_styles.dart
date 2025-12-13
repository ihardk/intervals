import 'package:flutter/material.dart';
import 'colors.dart';

/// Typography system for minimalist design
/// Sans-serif fonts with clear hierarchy
class AppTextStyles {
  // Display Styles (Large headings)
  static const displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    color: AppColors.black,
    letterSpacing: -0.5,
  );

  static const displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w300,
    color: AppColors.black,
    letterSpacing: -0.25,
  );

  static const displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w300,
    color: AppColors.black,
  );

  // Headline Styles
  static const headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );

  static const headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );

  static const headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  // Title Styles
  static const titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static const titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static const titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  // Body Styles
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    height: 1.5,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.grey3,
    height: 1.4,
  );

  // Label Styles
  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
    letterSpacing: 0.1,
  );

  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
    letterSpacing: 0.5,
  );

  static const labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.grey3,
    letterSpacing: 0.5,
  );

  // Button Styles
  static const button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
    letterSpacing: 0.5,
  );

  static const buttonSecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
    letterSpacing: 0.5,
  );

  // Caption Styles
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.grey4,
    letterSpacing: 0.4,
  );

  static const overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.grey4,
    letterSpacing: 1.5,
    textBaseline: TextBaseline.alphabetic,
  );

  // Private constructor to prevent instantiation
  AppTextStyles._();
}
