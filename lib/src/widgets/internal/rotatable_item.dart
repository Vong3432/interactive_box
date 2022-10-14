import 'package:flutter/material.dart';

/// A widget that can be rotated
class RotatableItem extends StatefulWidget {
  const RotatableItem(
      {super.key,
      required this.angle,
      required this.child,
      this.showRotatingIcon = false,
      this.onRotating,
      this.onPanEnd,
      this.alignment = Alignment.center});

  final double angle;
  final bool showRotatingIcon;
  final Widget child;
  final Alignment alignment;
  final Function(DragUpdateDetails)? onRotating;
  final Function(DragEndDetails)? onPanEnd;

  @override
  State<RotatableItem> createState() => _RotatableItemState();
}

class _RotatableItemState extends State<RotatableItem> {
  bool showRotatingIcon = false;

  final double rotateIconSize = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      showRotatingIcon = widget.showRotatingIcon;
    });
  }

  @override
  void didUpdateWidget(covariant RotatableItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.showRotatingIcon != widget.showRotatingIcon;

    setState(() {
      showRotatingIcon = widget.showRotatingIcon;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: widget.angle,
      alignment: widget.alignment,
      child: Stack(
        fit: StackFit.passthrough,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            right: -rotateIconSize - (20),
            // Gesture handler for the rotate icon indicator.
            child: Align(
              alignment: Alignment.centerRight,
              child: Opacity(
                opacity: showRotatingIcon ? 1.0 : 0.0,
                child: Icon(
                  Icons.circle,
                  color: Colors.lightGreen,
                  size: rotateIconSize,
                ),
              ),
            ),
          ),
          widget.child,
          Positioned(
            child: widget.showRotatingIcon
                ? GestureDetector(
                    onPanUpdate: (update) {
                      if (widget.onRotating != null) {
                        widget.onRotating!(update);
                        setState(() {
                          showRotatingIcon = true;
                        });
                      }
                    },
                    onPanEnd: ((details) {
                      if (widget.onPanEnd != null) {
                        widget.onPanEnd!(details);
                      }
                    }),
                  )
                : widget.child,
          ),
        ],
      ),
    );
  }
}
