import 'package:flutter/material.dart';

import '../../../consts/shape.const.dart';
import '../../../models/shape_style.dart';

class RectangleShape extends StatelessWidget {
  const RectangleShape({
    required this.width,
    required this.height,
    super.key,
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
      painter: RectangleShapePainter(
        width: width,
        height: height,
        style: style,
      ),
      child: child,
    );
  }
}

class RectangleShapePainter extends CustomPainter {
  final double width;
  final double height;
  final ShapeStyle? style;

  RectangleShapePainter({
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

    final square = Rect.fromLTWH(0, 0, width, height);
    canvas.drawRect(square, fillPaint);
    canvas.drawRect(square, paint);
  }

  @override
  bool shouldRepaint(covariant RectangleShapePainter oldDelegate) {
    return oldDelegate.style != style ||
        oldDelegate.width != width ||
        oldDelegate.height != height;
  }
}
