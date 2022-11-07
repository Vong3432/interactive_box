import 'package:flutter/material.dart';

@immutable
class InteractiveBoxInfo {
  final Size size;
  final Offset position;
  final double rotateAngle;

  const InteractiveBoxInfo({
    required this.size,
    required this.position,
    required this.rotateAngle,
  });

  InteractiveBoxInfo copyWith(
      {Size? size, Offset? position, double? rotateAngle}) {
    return InteractiveBoxInfo(
      size: size ?? this.size,
      position: position ?? this.position,
      rotateAngle: rotateAngle ?? this.rotateAngle,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map["width"] = size.width;
    map["height"] = size.height;
    map["x"] = position.dx;
    map["y"] = position.dy;
    map["rotateAngle"] = rotateAngle;

    return map;
  }
}
