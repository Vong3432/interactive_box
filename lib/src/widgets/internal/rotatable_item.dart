import 'package:flutter/material.dart';

/// A widget that can be rotated
class RotatableItem extends StatefulWidget {
  const RotatableItem(
      {super.key,
      required this.initialRotateAngle,
      required this.child,
      this.rotateIndicator,
      this.rotateIndicatorSpacing,
      this.showRotatingIcon = false,
      this.onRotating,
      this.onRotatingEnd,
      this.alignment = Alignment.center});

  final double initialRotateAngle;
  final bool showRotatingIcon;
  final Widget? rotateIndicator;
  final double? rotateIndicatorSpacing;
  final Widget child;
  final Alignment alignment;
  final void Function(double currentAngle)? onRotating;
  final void Function(double finalAngle)? onRotatingEnd;

  @override
  State<RotatableItem> createState() => _RotatableItemState();
}

class _RotatableItemState extends State<RotatableItem> {
  bool _showRotatingIcon = false;

  /// The starting angle when users first contact with the widget on screen.
  double _startingAngle = 0.0;

  /// The previous [_finalAngle].
  double _prevAngle = 0.0;

  /// The current rotation angle.
  double _finalAngle = 0.0;

  @override
  void initState() {
    super.initState();
    setState(() {
      _showRotatingIcon = widget.showRotatingIcon;
      _finalAngle = widget.initialRotateAngle;
    });
  }

  @override
  void didUpdateWidget(covariant RotatableItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.showRotatingIcon != widget.showRotatingIcon;

    _showRotatingIcon = widget.showRotatingIcon;
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _finalAngle,
      alignment: widget.alignment,
      child: Stack(
        fit: StackFit.passthrough,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            right: -(widget.rotateIndicatorSpacing ?? 20.0),
            // Gesture handler for the rotate icon indicator.
            child: Align(
              alignment: Alignment.centerRight,
              child: Opacity(
                opacity: _showRotatingIcon ? 1.0 : 0.0,
                child: widget.rotateIndicator ??
                    const Icon(
                      Icons.circle,
                      color: Colors.lightGreen,
                      size: 10,
                    ),
              ),
            ),
          ),
          widget.child,
          Positioned(
            child: widget.showRotatingIcon
                ? GestureDetector(
                    ///
                    /// The following code is retrived from stackoverflow.
                    /// ref: https://stackoverflow.com/a/54098497
                    /// Author: @SEG.Veenstra
                    ///
                    onPanStart: (details) {
                      _startingAngle = details.localPosition.direction;
                    },
                    onPanUpdate: (details) {
                      double tempAngle = 0.0;

                      setState(() {
                        _showRotatingIcon = true;
                        tempAngle = details.localPosition.direction -
                            _startingAngle +
                            _prevAngle;
                        _finalAngle = tempAngle;
                      });

                      if (widget.onRotating != null) {
                        widget.onRotating!(tempAngle);
                      }
                    },
                    onPanEnd: (details) {
                      _prevAngle = _finalAngle;
                      if (widget.onRotatingEnd != null) {
                        widget.onRotatingEnd!(_finalAngle);
                      }
                    },
                  )
                : widget.child,
          ),
        ],
      ),
    );
  }
}
