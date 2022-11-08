import 'package:flutter/material.dart';
import '../../consts/scale_item.const.dart';
import '../../enums/scale_direction_enum.dart';

class ScalableItem extends StatelessWidget {
  const ScalableItem({
    super.key,
    required this.child,
    required this.showCornerDots,
    required this.includedScaleDirections,
    // this.dot,
    this.showOverScaleBorder = false,
    this.onBottomLeftDotDragging,
    this.onBottomCenterDotDragging,
    this.onBottomRightDotDragging,
    this.onTopLeftDotDragging,
    this.onTopCenterDotDragging,
    this.onTopRightDotDragging,
    this.onCenterLeftDotDragging,
    this.onCenterRightDotDragging,
    this.cornerDotColor = defaultDotColor,
    this.overScaleCornerDotColor = defaultOverscaleDotColor,
    this.onAnyDotDraggingEnd,
    this.overScaleBorderDecoration,
    this.defaultScaleBorderDecoration,
  });

  final Widget child;
  // final Widget? dot;
  final Color cornerDotColor;
  final Color overScaleCornerDotColor;
  final bool showCornerDots;
  final bool showOverScaleBorder;
  final Decoration? overScaleBorderDecoration;
  final Decoration? defaultScaleBorderDecoration;
  final Function(DragUpdateDetails)? onTopLeftDotDragging;
  final Function(DragUpdateDetails)? onTopCenterDotDragging;
  final Function(DragUpdateDetails)? onTopRightDotDragging;
  final Function(DragUpdateDetails)? onBottomLeftDotDragging;
  final Function(DragUpdateDetails)? onBottomCenterDotDragging;
  final Function(DragUpdateDetails)? onBottomRightDotDragging;
  final Function(DragUpdateDetails)? onCenterLeftDotDragging;
  final Function(DragUpdateDetails)? onCenterRightDotDragging;
  final Function(DragEndDetails)? onAnyDotDraggingEnd;
  final List<ScaleDirection> includedScaleDirections;

  @override
  Widget build(BuildContext context) {
    final Color computedDotColor = showCornerDots
        ? showOverScaleBorder
            ? overScaleCornerDotColor
            : cornerDotColor
        : Colors.transparent;

    final Decoration localOverScaleBorderDecoration =
        overScaleBorderDecoration ??
            BoxDecoration(
              border: Border.all(
                width: defaultScaleBorderWidth,
                color: computedDotColor,
              ),
              shape: BoxShape.rectangle,
            );

    final Decoration localDefaultScaleBorderDecoration =
        defaultScaleBorderDecoration ??
            BoxDecoration(
              border: Border.all(
                width: defaultScaleBorderWidth,
                color: Colors.grey[100]!,
              ),
              shape: BoxShape.rectangle,
            );

    final Decoration borderDecoration = showOverScaleBorder
        ? localOverScaleBorderDecoration
        : localDefaultScaleBorderDecoration;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        // child
        Positioned.fill(
          child: child,
        ),

        Positioned.fill(
          child: Container(
            decoration: borderDecoration,
          ),
        ),

        // top left
        if (includedScaleDirections.contains(ScaleDirection.topLeft))
          GestureDetector(
            onPanUpdate: (details) {
              if (onTopLeftDotDragging != null) {
                onTopLeftDotDragging!(details);
              }
            },
            onPanEnd: ((details) {
              if (onAnyDotDraggingEnd != null) {
                onAnyDotDraggingEnd!(details);
              }
            }),
            child: Container(
              alignment: Alignment.topLeft,
              child: _buildDot(computedDotColor),
            ),
          ),

        // top center
        if (includedScaleDirections.contains(ScaleDirection.topCenter))
          GestureDetector(
            onPanUpdate: (details) {
              if (onTopCenterDotDragging != null) {
                onTopCenterDotDragging!(details);
              }
            },
            onPanEnd: ((details) {
              if (onAnyDotDraggingEnd != null) {
                onAnyDotDraggingEnd!(details);
              }
            }),
            child: Container(
              alignment: Alignment.topCenter,
              child: _buildDot(computedDotColor),
            ),
          ),

        // top right
        if (includedScaleDirections.contains(ScaleDirection.topRight))
          GestureDetector(
            onPanUpdate: (details) {
              if (onTopRightDotDragging != null) {
                onTopRightDotDragging!(details);
              }
            },
            onPanEnd: ((details) {
              if (onAnyDotDraggingEnd != null) {
                onAnyDotDraggingEnd!(details);
              }
            }),
            child: Container(
              alignment: Alignment.topRight,
              child: _buildDot(computedDotColor),
            ),
          ),

        // bottom left
        if (includedScaleDirections.contains(ScaleDirection.bottomLeft))
          GestureDetector(
            onPanUpdate: (details) {
              if (onBottomLeftDotDragging != null) {
                onBottomLeftDotDragging!(details);
              }
            },
            onPanEnd: ((details) {
              if (onAnyDotDraggingEnd != null) {
                onAnyDotDraggingEnd!(details);
              }
            }),
            child: Container(
              alignment: Alignment.bottomLeft,
              child: _buildDot(computedDotColor),
            ),
          ),

        // bottom center
        if (includedScaleDirections.contains(ScaleDirection.bottomCenter))
          GestureDetector(
            onPanUpdate: (details) {
              if (onBottomCenterDotDragging != null) {
                onBottomCenterDotDragging!(details);
              }
            },
            onPanEnd: ((details) {
              if (onAnyDotDraggingEnd != null) {
                onAnyDotDraggingEnd!(details);
              }
            }),
            child: Container(
              alignment: Alignment.bottomCenter,
              child: _buildDot(computedDotColor),
            ),
          ),

        // bottom right
        if (includedScaleDirections.contains(ScaleDirection.bottomRight))
          GestureDetector(
            onPanUpdate: (details) {
              if (onBottomRightDotDragging != null) {
                onBottomRightDotDragging!(details);
              }
            },
            onPanEnd: ((details) {
              if (onAnyDotDraggingEnd != null) {
                onAnyDotDraggingEnd!(details);
              }
            }),
            child: Container(
              alignment: Alignment.bottomRight,
              child: _buildDot(computedDotColor),
            ),
          ),

        // center left
        if (includedScaleDirections.contains(ScaleDirection.centerLeft))
          GestureDetector(
            onPanUpdate: (details) {
              if (onCenterLeftDotDragging != null) {
                onCenterLeftDotDragging!(details);
              }
            },
            onPanEnd: ((details) {
              if (onAnyDotDraggingEnd != null) {
                onAnyDotDraggingEnd!(details);
              }
            }),
            child: Container(
              alignment: Alignment.centerLeft,
              child: _buildDot(computedDotColor),
            ),
          ),

        // center right
        if (includedScaleDirections.contains(ScaleDirection.centerRight))
          GestureDetector(
            onPanUpdate: (details) {
              if (onCenterRightDotDragging != null) {
                onCenterRightDotDragging!(details);
              }
            },
            onPanEnd: ((details) {
              if (onAnyDotDraggingEnd != null) {
                onAnyDotDraggingEnd!(details);
              }
            }),
            child: Container(
              alignment: Alignment.centerRight,
              child: _buildDot(computedDotColor),
            ),
          ),
      ],
    );
  }

  Widget _buildDot(Color color) {
    return Icon(
      Icons.square,
      size: 18,
      color: color,
    );
  }
}
