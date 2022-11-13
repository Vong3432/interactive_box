import 'package:flutter/material.dart';

import '../../../consts/shape.const.dart';
import '../../../models/shape_style.dart';

class OvalShape extends StatelessWidget {
  const OvalShape({
    super.key,
    required this.width,
    required this.height,
    this.style,
    this.child,
  });

  final double width;
  final double height;
  final ShapeStyle? style;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: OvalShapePainter(
        width: width,
        height: height,
        style: style,
      ),
      child: child,
    );
  }
}

class OvalShapePainter extends CustomPainter {
  final double width;
  final double height;
  final ShapeStyle? style;

  OvalShapePainter({
    required this.width,
    required this.height,
    this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = style?.borderWidth ?? defaultBorderWidth
      ..color = style?.borderColor ?? defaultBorderColor
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..color = style?.backgroundColor ?? defaultBackgroundColor
      ..style = PaintingStyle.fill;
    final oval = Rect.fromLTWH(0, 0, width, height);

    canvas.drawOval(oval, fillPaint);
    canvas.drawOval(oval, paint);
  }

  @override
  bool shouldRepaint(covariant OvalShapePainter oldDelegate) {
    return false;
  }
}
