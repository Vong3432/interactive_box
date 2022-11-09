import 'package:flutter/material.dart';

import '../../../consts/shape.const.dart';
import '../../../models/shape_style.dart';

class CircleShape extends StatelessWidget {
  const CircleShape({
    super.key,
    required this.radius,
    this.style,
    this.child,
  });

  final double radius;
  final ShapeStyle? style;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CircleShapePainter(
        radius: radius,
        style: style,
      ),
      child: child,
    );
  }
}

class CircleShapePainter extends CustomPainter {
  final double radius;
  final ShapeStyle? style;

  CircleShapePainter({
    required this.radius,
    this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double borderWidth = style?.borderWidth ?? defaultBorderWidth;
    final paint = Paint()
      ..strokeWidth = borderWidth
      ..color = style?.borderColor ?? defaultBorderColor
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..color = style?.backgroundColor ?? defaultBackgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(
        radius,
        radius,
      ),
      radius,
      fillPaint,
    );

    canvas.drawCircle(
      Offset(
        radius,
        radius,
      ),
      radius,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CircleShapePainter oldDelegate) {
    return oldDelegate.style != style || oldDelegate.radius != radius;
  }
}
