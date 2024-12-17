import 'package:flutter/material.dart';

extension SizedBoxExtensionInt on int {
  SizedBox get h => SizedBox(height: toDouble());
  SizedBox get w => SizedBox(width: toDouble());
}

extension SizedBoxExtensionDouble on double {
  SizedBox get h => SizedBox(height: this);
  SizedBox get w => SizedBox(width: this);
}

extension ColorValueExt on Color {
  int _floatToInt8(double a) => (a * 255.0).round() & 0xff;

  int get getValue =>
      _floatToInt8(a) << 24 | _floatToInt8(r) << 16 | _floatToInt8(g) << 8 | _floatToInt8(b) << 0;
}
