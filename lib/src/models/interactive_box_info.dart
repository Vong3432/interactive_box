import 'package:flutter/material.dart';

@immutable
class InteractiveBoxInfo {
  final double width;
  final double height;
  final double x;
  final double y;
  final double rotateAngle;

  const InteractiveBoxInfo({
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    required this.rotateAngle,
  });

  InteractiveBoxInfo copyWith(
      {double? width,
      double? height,
      double? x,
      double? y,
      double? rotateAngle}) {
    return InteractiveBoxInfo(
      width: width ?? this.width,
      height: height ?? this.height,
      x: x ?? this.x,
      y: y ?? this.y,
      rotateAngle: rotateAngle ?? this.rotateAngle,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map["width"] = width;
    map["height"] = height;
    map["x"] = x;
    map["y"] = y;
    map["rotateAngle"] = rotateAngle;

    return map;
  }
}
