import 'package:defer_pointer/defer_pointer.dart';
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
  final void Function(DragUpdateDetails details, double currentAngle)?
      onRotating;
  final void Function(DragEndDetails details, double finalAngle)? onRotatingEnd;

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
    if (oldWidget.showRotatingIcon != widget.showRotatingIcon) {
      _showRotatingIcon = widget.showRotatingIcon;
      super.didUpdateWidget(oldWidget);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DeferredPointerHandler(
      child: Transform.rotate(
        angle: _finalAngle,
        alignment: widget.alignment,
        child: Stack(
          fit: StackFit.passthrough,
          clipBehavior: Clip.none,
          children: [
            widget.child,
            if (_showRotatingIcon)
              Positioned.fill(
                right: -(widget.rotateIndicatorSpacing ?? 50),
                child: DeferPointer(
                  child: GestureDetector(
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
                        widget.onRotating!(details, tempAngle);
                      }
                    },
                    onPanEnd: (details) {
                      _prevAngle = _finalAngle;
                      if (widget.onRotatingEnd != null) {
                        widget.onRotatingEnd!(details, _finalAngle);
                      }
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Opacity(
                        opacity: _showRotatingIcon ? 1.0 : 0.0,
                        child: widget.rotateIndicator ??
                            const Icon(
                              Icons.rotate_90_degrees_ccw_outlined,
                              color: Colors.lightGreen,
                              size: 50,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
