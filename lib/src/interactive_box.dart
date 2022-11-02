import 'dart:math';

import 'package:flutter/material.dart';

import 'models/interactive_box_info.dart';
import 'typedef.dart';
import 'consts/scale_item.const.dart';
import 'consts/circular_menu.const.dart';
import 'enums/control_action_type_enum.dart';
import 'enums/scale_direction_enum.dart';
import 'widgets/internal/circular_menu_item.dart';
import 'widgets/internal/multiple_circular_menu.dart';
import 'widgets/internal/rotatable_item.dart';
import 'widgets/internal/scalable_item.dart';

/// A widget that supports controllable actions from [ControlActionType].
class InteractiveBox extends StatefulWidget {
  const InteractiveBox({
    Key? key,
    required this.child,
    required this.initialWidth,
    required this.initialHeight,
    this.maxWidth,
    this.maxHeight,
    this.includedActions = const [
      ControlActionType.copy,
      ControlActionType.delete,
      ControlActionType.rotate,
      ControlActionType.scale,
      ControlActionType.move,
      ControlActionType.none
    ],
    this.initialShowActionIcons = false,
    this.hideActionIconsWhenInteracting = true,
    this.circularMenuDegree,
    // this.circularMenuSpreadMultiplier = defaultSpreadDistanceMultiplier,
    this.showOverscaleBorder = true,
    this.overScaleBorderDecoration,
    this.defaultScaleBorderDecoration,
    this.iconSize = defaultIconSize,
    this.circularMenuIconColor = defaultMenuIconColor,
    this.copyIcon = const Icon(Icons.copy),
    this.scaleIcon = const Icon(Icons.zoom_out_map_outlined),
    this.rotateIcon = const Icon(Icons.rotate_right),
    this.deleteIcon = const Icon(Icons.delete),
    this.cancelIcon = const Icon(Icons.cancel),
    this.rotateIndicator,
    this.rotateIndicatorSpacing,
    this.initialRotateAngle = 0.0,
    this.initialX = 0.0,
    this.initialY = 0.0,
    this.onActionSelected,
    this.onInteractiveActionPerforming,
    this.onInteractiveActionPerformed,
    this.onTap,
    this.scaleDotColor = defaultDotColor,
    this.overScaleDotColor = defaultOverscaleDotColor,
    // this.dot,
  }) : super(key: key);

  /// Whether the border should show a border when overscaled.
  final bool showOverscaleBorder;
  final Decoration? overScaleBorderDecoration;

  /// Default decoration for scale border
  final Decoration? defaultScaleBorderDecoration;

  final bool initialShowActionIcons;

  /// Whether the action icons should be hidden when users interacting.
  ///
  /// Users-interactive actions:
  /// - [ControlActionType.rotate]
  /// - [ControlActionType.scale]
  /// - [ControlActionType.move]
  ///
  final bool hideActionIconsWhenInteracting;

  final double initialX;
  final double initialY;
  final double initialWidth;
  final double initialHeight;

  /// The maximum width that the [child] can be scaled
  final double? maxWidth;

  /// The maximum height that the [child] can be scaled
  final double? maxHeight;

  /// The rotate angle for [child].
  final double initialRotateAngle;

  /// Default will include all supported actions.
  final List<ControlActionType> includedActions;
  final Widget child;

  /// The full degree wanted for the circular menu.
  final double? circularMenuDegree;

  /// Distance of the spread distance between the [child] and the circular menu.
  // final double circularMenuSpreadMultiplier;

  /// A callback that will be called whenever an action (by pressing icon) is selected
  final ActionSelectedCallback? onActionSelected;

  /// A callback that will be called when performing interactive actions.
  final OnInteractiveActionPerforming? onInteractiveActionPerforming;

  /// A callback that will be called after performing interactive actions.
  final OnInteractiveActionPerformed? onInteractiveActionPerformed;

  final OnTapCallback? onTap;

  final Color circularMenuIconColor;
  final double iconSize;
  final Widget copyIcon;
  final Widget scaleIcon;
  final Widget rotateIcon;
  final Widget deleteIcon;
  final Widget cancelIcon;

  final Widget? rotateIndicator;
  final double? rotateIndicatorSpacing;

  final Color scaleDotColor;
  final Color overScaleDotColor;
  // final Widget? dot;

  @override
  InteractiveBoxState createState() => InteractiveBoxState();
}

class InteractiveBoxState extends State<InteractiveBox> {
  late bool _showItems;
  late double _width;
  late double _height;

  bool _isPerforming = false;
  double _x = 0.0;
  double _y = 0.0;
  double _rotateAngle = 0.0;
  ControlActionType _selectedAction = ControlActionType.none;

  @override
  void initState() {
    super.initState();

    _showItems = widget.initialShowActionIcons;
    _x = widget.initialX;
    _y = widget.initialY;
    _width = widget.initialWidth;
    _height = widget.initialHeight;
    _rotateAngle = widget.initialRotateAngle;
  }

  @override
  void didUpdateWidget(InteractiveBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialShowActionIcons != widget.initialShowActionIcons) {
      _showItems = widget.initialShowActionIcons;
    }
    if (oldWidget.initialWidth != widget.initialWidth) {
      _width = widget.initialWidth;
    }
    if (oldWidget.initialHeight != widget.initialHeight) {
      _height = widget.initialHeight;
    }
    if (oldWidget.initialX != widget.initialX) {
      _x = widget.initialX;
    }
    if (oldWidget.initialY != widget.initialY) {
      _y = widget.initialY;
    }
    if (oldWidget.initialRotateAngle != widget.initialRotateAngle) {
      _rotateAngle = widget.initialRotateAngle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isRotating = _selectedAction == ControlActionType.rotate;
    final bool isScaling = _selectedAction == ControlActionType.scale;
    final bool isOverScale =
        _isWidthOverscale(_width) && _isHeightOverscale(_height);

    Widget child = widget.child;

    /// Build widget tree of [child] from the bottom to the top.
    ///
    /// Widget order matters.
    ///
    /// For instance, if we do Scaling > Rotating, then the widget will be rotated but the scaling
    /// dots and borders will not be rotated.
    ///
    /// (From Top to Bottom, Gesture is the Top.)
    /// - GestureDetector > MultipleCircularMenu > Rotating > Scaling
    ///
    ///

    // Scaling, this is the bottomest.
    if (widget.includedActions.contains(ControlActionType.scale)) {
      child = ScalableItem(
        // dot: widget.dot,
        cornerDotColor: widget.scaleDotColor,
        overScaleCornerDotColor: widget.overScaleDotColor,
        overScaleBorderDecoration: widget.overScaleBorderDecoration,
        defaultScaleBorderDecoration: widget.defaultScaleBorderDecoration,
        showOverScaleBorder: isOverScale && widget.showOverscaleBorder,
        onAnyDotDraggingEnd: (details) {
          _onScalingEnd(details);
        },
        onTopLeftDotDragging: (details) {
          _onScaling(details, ScaleDirection.topLeft);
        },
        onTopCenterDotDragging: (details) {
          _onScaling(details, ScaleDirection.topCenter);
        },
        onTopRightDotDragging: (details) {
          _onScaling(details, ScaleDirection.topRight);
        },
        onBottomLeftDotDragging: (details) {
          _onScaling(details, ScaleDirection.bottomLeft);
        },
        onBottomCenterDotDragging: (details) {
          _onScaling(details, ScaleDirection.bottomCenter);
        },
        onBottomRightDotDragging: (details) {
          _onScaling(details, ScaleDirection.bottomRight);
        },
        onCenterLeftDotDragging: (details) {
          _onScaling(details, ScaleDirection.centerLeft);
        },
        onCenterRightDotDragging: (details) {
          _onScaling(details, ScaleDirection.centerRight);
        },
        showCornerDots: isScaling,
        child: child,
      );
    } else {
      child = Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: defaultScaleBorderWidth,
            color: Colors.transparent,
          ),
          shape: BoxShape.rectangle,
        ),
        child: child,
      );
    }

    // Rotating
    if (widget.includedActions.contains(ControlActionType.rotate)) {
      child = RotatableItem(
        rotateIndicatorSpacing: widget.rotateIndicatorSpacing,
        rotateIndicator: widget.rotateIndicator,
        showRotatingIcon: isRotating,
        initialRotateAngle: widget.initialRotateAngle,
        onRotating: (rotateAngle) {
          _rotateAngle = rotateAngle;
          _notifyParentWhenInteracting();
          _toggleIsPerforming(true);
        },
        onRotatingEnd: (double finalAngle) {
          _rotateAngle = finalAngle;
          _notifyParentAfterInteracted();
          _toggleIsPerforming(false);
        },
        child: child,
      );
    }

    child = MultipleCircularMenu(
      x: _x,
      y: _y,
      degree: widget.circularMenuDegree ?? defaultCircularMenuDegree,
      // spreadDistanceMultiplier: widget.circularMenuSpreadMultiplier,
      iconSize: widget.iconSize,
      childWidth: _width,
      childHeight: _height,
      showItems: _showItems && !_isPerforming,
      items: _buildActionItems(),
      child: child,
    );

    /// Here is the topest in the widget tree of [child]
    child = RepaintBoundary(
      child: SizedBox.expand(
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _selectedAction = ControlActionType.move;
            });

            if (!widget.includedActions.contains(ControlActionType.move)) {
              return;
            }

            _onMoving(details);
          },
          onPanEnd: (details) {
            if (!widget.includedActions.contains(ControlActionType.move)) {
              return;
            }

            _onMovingEnd(details);
          },
          onTap: () {
            if (widget.onTap != null) {
              final InteractiveBoxInfo info = _getCurrentBoxInfo;
              widget.onTap!(info);
            }

            setState(() {
              _showItems = !_showItems;
            });
          },
          child: child,
        ),
      ),
    );

    return child;
  }

  void _toggleIsPerforming(bool perform) {
    if (!perform) {
      // Make selectedAction to none again when users released
      setState(() {
        _selectedAction = ControlActionType.none;
      });
    }

    if (widget.hideActionIconsWhenInteracting) {
      setState(() {
        _isPerforming = perform;
      });
    }
  }

  List<Widget> _buildActionItems() {
    List<ControlActionType> unique = widget.includedActions
        .toSet()
        .where((element) =>
            element !=
            ControlActionType.move) // since we will not show icon for move
        .toList();

    return List.generate(
      unique.length,
      (index) {
        ControlActionType actionType = unique[index];

        bool isInteractiveAction = true;
        Widget? icon;

        switch (actionType) {
          case ControlActionType.copy:
            icon = widget.copyIcon;
            isInteractiveAction = false;
            break;
          case ControlActionType.scale:
            icon = widget.scaleIcon;
            break;
          case ControlActionType.rotate:
            icon = widget.rotateIcon;
            break;
          case ControlActionType.delete:
            isInteractiveAction = false;
            icon = widget.deleteIcon;
            break;
          case ControlActionType.none:
            isInteractiveAction = false;
            icon = widget.cancelIcon;
            break;
          case ControlActionType.move:
            return Container();
        }

        return CircularMenuItem(
          iconColor: widget.circularMenuIconColor,
          iconSize: widget.iconSize,
          icon: icon,
          onPressed: () {
            final InteractiveBoxInfo info = _getCurrentBoxInfo;

            setState(() {
              _selectedAction = actionType;
            });

            if (widget.onActionSelected != null) {
              widget.onActionSelected!(actionType, info);
            }

            if (!isInteractiveAction) {
              // Close circular menu items for non-interactive action
              // and reset the current action to none.
              setState(() {
                _showItems = false;
              });
              _toggleIsPerforming(false);
            }
          },
          actionType: actionType,
        );
      },
    );
  }

  /// Users can only be allowed to interact with the controllable item before releasing the cursor.
  /// Once it is released, no more interaction.
  void _onMovingEnd(DragEndDetails details) {
    _notifyParentAfterInteracted();
    _toggleIsPerforming(false);
  }

  void _onMoving(DragUpdateDetails update) {
    // only moving when actiontype is move
    if (_selectedAction != ControlActionType.move) {
      return;
    }

    _toggleIsPerforming(true);

    double updatedXPosition = _x;
    double updatedYPosition = _y;

    updatedXPosition += (update.delta.dx);
    updatedYPosition += (update.delta.dy);

    setState(() {
      _x = updatedXPosition;
      _y = updatedYPosition;
    });

    _notifyParentWhenInteracting();
  }

  void _onScalingEnd(DragEndDetails details) {
    // only update when actiontype is scaling
    if (_selectedAction != ControlActionType.scale) {
      return;
    }

    _notifyParentAfterInteracted();
    _toggleIsPerforming(false);
  }

  void _onScaling(
    DragUpdateDetails update,
    ScaleDirection scaleDirection,
  ) {
    // only update when actiontype is scaling
    if (_selectedAction != ControlActionType.scale) {
      return;
    }

    _toggleIsPerforming(true);

    double dx = update.delta.dx;
    double dy = update.delta.dy;

    double updatedWidth = _width;
    double updatedHeight = _height;
    double updatedXPosition = _x;
    double updatedYPosition = _y;

    ///
    /// Scale widget from corners calculation
    ///
    /// ref: https://stackoverflow.com/a/60964980
    /// Author: @Kherel
    ///
    /// Rotational offset
    /// - Fix x, y position after scaling if rotated
    ///
    /// https://stackoverflow.com/a/73930511
    /// Author: @Steve
    ///
    switch (scaleDirection) {
      case ScaleDirection.centerLeft:
        double newWidth = updatedWidth - dx;

        updatedWidth = newWidth > 0 ? newWidth : 0;

        // left
        var rotationalOffset = Offset(
              cos(_rotateAngle) + 1, // x
              sin(_rotateAngle), // y
            ) *
            update.delta.dx /
            2;
        updatedXPosition += rotationalOffset.dx;
        updatedYPosition += rotationalOffset.dy;

        break;

      case ScaleDirection.centerRight:
        double newWidth = updatedWidth + dx;
        updatedWidth = newWidth > 0 ? newWidth : 0;

        // right
        var rotationalOffset = Offset(
              cos(_rotateAngle) - 1, // x
              sin(_rotateAngle), // y
            ) *
            update.delta.dx /
            2;
        updatedXPosition += rotationalOffset.dx;
        updatedYPosition += rotationalOffset.dy;

        break;
      case ScaleDirection.topLeft:
        double newHeight = updatedHeight -= dy;
        double newWidth = updatedWidth - dx;

        updatedHeight = newHeight > 0 ? newHeight : 0;
        updatedWidth = newWidth > 0 ? newWidth : 0;

        // left
        var rotationalOffset = Offset(
              cos(_rotateAngle) + 1, // x
              sin(_rotateAngle), // y
            ) *
            update.delta.dx /
            2;
        // top
        var rotationalOffset2 = Offset(
              -sin(_rotateAngle),
              cos(_rotateAngle) + 1,
            ) *
            update.delta.dy /
            2;

        updatedXPosition += rotationalOffset.dx + rotationalOffset2.dx;
        updatedYPosition += rotationalOffset.dy + rotationalOffset2.dy;

        break;

      case ScaleDirection.topCenter:
        double newHeight = updatedHeight -= dy;
        updatedHeight = newHeight > 0 ? newHeight : 0;

        // top
        var rotationalOffset = Offset(
              -sin(_rotateAngle),
              cos(_rotateAngle) + 1,
            ) *
            update.delta.dy /
            2;

        updatedXPosition += rotationalOffset.dx;
        updatedYPosition += rotationalOffset.dy;

        break;

      case ScaleDirection.topRight:
        double newHeight = updatedHeight -= dy;
        double newWidth = updatedWidth + dx;

        updatedHeight = newHeight > 0 ? newHeight : 0;
        updatedWidth = newWidth > 0 ? newWidth : 0;

        // right
        var rotationalOffset = Offset(
              cos(_rotateAngle) - 1, // x
              sin(_rotateAngle), // y
            ) *
            update.delta.dx /
            2;
        // top
        var rotationalOffset2 = Offset(
              -sin(_rotateAngle),
              cos(_rotateAngle) + 1,
            ) *
            update.delta.dy /
            2;

        updatedXPosition += rotationalOffset.dx + rotationalOffset2.dx;
        updatedYPosition += rotationalOffset.dy + rotationalOffset2.dy;

        break;

      case ScaleDirection.bottomLeft:
        double newHeight = updatedHeight + dy;
        double newWidth = updatedWidth - dx;

        updatedWidth = newWidth > 0 ? newWidth : 0;
        updatedHeight = newHeight > 0 ? newHeight : 0;

        // left
        var rotationalOffset = Offset(
              cos(_rotateAngle) + 1, // x
              sin(_rotateAngle), // y
            ) *
            update.delta.dx /
            2;
        // bottom
        var rotationalOffset2 = Offset(
              -sin(_rotateAngle),
              cos(_rotateAngle) - 1,
            ) *
            update.delta.dy /
            2;

        updatedXPosition += rotationalOffset.dx + rotationalOffset2.dx;
        updatedYPosition += rotationalOffset.dy + rotationalOffset2.dy;

        break;
      case ScaleDirection.bottomCenter:
        double newHeight = updatedHeight + dy;
        updatedHeight = newHeight > 0 ? newHeight : 0;

        // bottom
        var rotationalOffset = Offset(
              -sin(_rotateAngle),
              cos(_rotateAngle) - 1,
            ) *
            update.delta.dy /
            2;

        updatedXPosition += rotationalOffset.dx;
        updatedYPosition += rotationalOffset.dy;

        break;
      case ScaleDirection.bottomRight:
        double newHeight = updatedHeight + dy;
        double newWidth = updatedWidth + dx;

        // right
        var rotationalOffset = Offset(
              cos(_rotateAngle) - 1, // x
              sin(_rotateAngle), // y
            ) *
            update.delta.dx /
            2;
        // bottom
        var rotationalOffset2 = Offset(
              -sin(_rotateAngle),
              cos(_rotateAngle) - 1,
            ) *
            update.delta.dy /
            2;

        updatedXPosition += rotationalOffset.dx + rotationalOffset2.dx;
        updatedYPosition += rotationalOffset.dy + rotationalOffset2.dy;
        updatedWidth = newWidth > 0 ? newWidth : 0;
        updatedHeight = newHeight > 0 ? newHeight : 0;

        break;
      default:
    }

    if (_isWidthOverscale(updatedWidth)) {
      updatedXPosition = _x;
      updatedWidth = widget.maxWidth!;
    }

    if (_isHeightOverscale(updatedHeight)) {
      updatedYPosition = _y;
      updatedHeight = widget.maxHeight!;
    }

    setState(() {
      _width = updatedWidth;
      _height = updatedHeight;
      _x = updatedXPosition;
      _y = updatedYPosition;
    });

    _notifyParentWhenInteracting();
  }

  bool _isWidthOverscale(double width) {
    if (widget.maxWidth == null) return false;

    return width >= widget.maxWidth!;
  }

  bool _isHeightOverscale(double height) {
    if (widget.maxHeight == null) return false;

    return height >= widget.maxHeight!;
  }

  InteractiveBoxInfo get _getCurrentBoxInfo => InteractiveBoxInfo(
        width: _width,
        height: _height,
        x: _x,
        y: _y,
        rotateAngle: _rotateAngle,
      );

  final List<ControlActionType> _interactiveActions = [
    ControlActionType.move,
    ControlActionType.scale,
    ControlActionType.rotate,
  ];

  void _notifyParentWhenInteracting() {
    if (!_interactiveActions.contains(_selectedAction)) return;

    if (widget.onInteractiveActionPerforming != null) {
      widget.onInteractiveActionPerforming!(
          _selectedAction, _getCurrentBoxInfo);
    }
  }

  void _notifyParentAfterInteracted() {
    if (!_interactiveActions.contains(_selectedAction)) return;

    if (widget.onInteractiveActionPerformed != null) {
      widget.onInteractiveActionPerformed!(_selectedAction, _getCurrentBoxInfo);
    }
  }
}
