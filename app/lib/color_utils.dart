import 'package:flutter/material.dart';

class ColorUtils {
  static int opacityToAlpha(double opacity) {
    return (opacity * 255).round();
  }

  static Color withAlphaFromOpacity(Color color, double opacity) {
    return color.withAlpha(opacityToAlpha(opacity));
  }

  static const int alpha5Percent = 13;
  static const int alpha10Percent = 26;
  static const int alpha20Percent = 51;
  static const int alpha30Percent = 77;
  static const int alpha50Percent = 128;
  static const int alpha70Percent = 179;

  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withAlpha(alpha5Percent),
    blurRadius: 10,
    offset: const Offset(0, 2),
  );
}

extension ColorExtension on Color {
  Color withAlphaValue(int alpha) {
    return withAlpha(alpha);
  }
}
