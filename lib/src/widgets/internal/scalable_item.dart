import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../consts/scale_item.const.dart';

class ScalableItem extends StatelessWidget {
  const ScalableItem({
    super.key,
    required this.child,
    required this.showDots,
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
    this.scaleDotColor = defaultDotColor,
    this.overScaleDotColor = defaultOverscaleDotColor,
    this.onAnyDotDraggingEnd,
    this.overScaleBorderDecoration,
  });

  final Widget child;
  // final Widget? dot;
  final Color scaleDotColor;
  final Color overScaleDotColor;
  final bool showDots;
  final bool showOverScaleBorder;
  final Decoration? overScaleBorderDecoration;
  final Function(DragUpdateDetails)? onTopLeftDotDragging;
  final Function(DragUpdateDetails)? onTopCenterDotDragging;
  final Function(DragUpdateDetails)? onTopRightDotDragging;
  final Function(DragUpdateDetails)? onBottomLeftDotDragging;
  final Function(DragUpdateDetails)? onBottomCenterDotDragging;
  final Function(DragUpdateDetails)? onBottomRightDotDragging;
  final Function(DragUpdateDetails)? onCenterLeftDotDragging;
  final Function(DragUpdateDetails)? onCenterRightDotDragging;
  final Function(DragEndDetails)? onAnyDotDraggingEnd;

  @override
  Widget build(BuildContext context) {
    final Color computedDotColor = showDots
        ? showOverScaleBorder
            ? overScaleDotColor
            : scaleDotColor
        : Colors.transparent;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: Container(
            decoration: overScaleBorderDecoration ??
                BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: computedDotColor,
                  ),
                  shape: BoxShape.rectangle,
                ),
            child: child,
          ),
        ),

        // top left
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
