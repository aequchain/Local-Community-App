import 'package:flutter/material.dart';

/// Centralized numerical system following aequus Fibonacci/prime directives.
class AequusDesignTokens {
  AequusDesignTokens._();

  static const spacing = _AequusSpacing();
  static const radii = _AequusRadii();
  static const durations = _AequusDurations();
  static const typography = _AequusTypography();

  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color successGreen = Color(0xFF34C759);
  static const Color ctaOrange = Color(0xFFFF9500);
  static const Color canvasLight = Color(0xFFF2F2F7);
  static const Color canvasDark = Color(0xFF0F1115);
}

class _AequusSpacing {
  const _AequusSpacing();

  double get s3 => 3;
  double get s5 => 5;
  double get s8 => 8;
  double get s13 => 13;
  double get s21 => 21;
  double get s34 => 34;
  double get s55 => 55;
  double get s89 => 89;
}

class _AequusRadii {
  const _AequusRadii();

  BorderRadius get s8 => BorderRadius.circular(8);
  BorderRadius get s13 => BorderRadius.circular(13);
  BorderRadius get s21 => BorderRadius.circular(21);
}

class _AequusDurations {
  const _AequusDurations();

  Duration get micro => const Duration(milliseconds: 34);
  Duration get fast => const Duration(milliseconds: 89);
  Duration get standard => const Duration(milliseconds: 233);
  Duration get relaxed => const Duration(milliseconds: 377);
  Duration get deliberate => const Duration(milliseconds: 610);
}

class _AequusTypography {
  const _AequusTypography();

  double get display => 34;
  double get headline => 21;
  double get title => 13;
  double get body => 13;
  double get caption => 8;
}
