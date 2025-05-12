// A simple utility class to replace withOpacity calls
// This file should be copied to a new utility class in the project
// to handle color manipulations
import 'package:flutter/material.dart';

class ColorUtils {
  // Convert opacity to alpha (0-255)
  static int opacityToAlpha(double opacity) {
    return (opacity * 255).round();
  }

  // Extension method for Color
  static Color withAlphaFromOpacity(Color color, double opacity) {
    return color.withAlpha(opacityToAlpha(opacity));
  }

  // Common alpha values
  static const int alpha5Percent = 13; // 0.05 * 255
  static const int alpha10Percent = 26; // 0.1 * 255
  static const int alpha20Percent = 51; // 0.2 * 255
  static const int alpha30Percent = 77; // 0.3 * 255
  static const int alpha50Percent = 128; // 0.5 * 255
  static const int alpha70Percent = 179; // 0.7 * 255
}

extension ColorExtension on Color {
  Color withAlphaValue(int alpha) {
    return withAlpha(alpha);
  }
}
