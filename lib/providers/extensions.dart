import 'package:flutter/material.dart';

extension SizedBoxExtensionInt on int {
  SizedBox get h => SizedBox(height: toDouble());
  SizedBox get w => SizedBox(width: toDouble());
}

extension SizedBoxExtensionDouble on double {
  SizedBox get h => SizedBox(height: this);
  SizedBox get w => SizedBox(width: this);
}
