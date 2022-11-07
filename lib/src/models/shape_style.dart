import 'package:flutter/material.dart';

import '../consts/shape.const.dart';

class ShapeStyle {
  final Color? borderColor;
  final double? borderWidth;
  final Color? backgroundColor;

  const ShapeStyle({
    this.borderWidth = defaultBorderWidth,
    this.borderColor = defaultBorderColor,
    this.backgroundColor = defaultBackgroundColor,
  });
}
