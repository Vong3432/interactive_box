import 'package:flutter/material.dart';

import 'typedef.dart';
import 'consts/scale_item.const.dart';
import 'consts/circular_menu.const.dart';
import 'enums/control_action_type_enum.dart';
import 'enums/scale_direction_enum.dart';
import 'widgets/internal/circular_menu_item.dart';
import 'widgets/internal/multiple_circular_menu.dart';
import 'widgets/internal/rotatable_item.dart';
import 'widgets/internal/scalable_item.dart';

import 'extensions/iterable.dart' show IterableDistinctExt;

/// A widget that can write support custom logic for controllable actions from [ControlActionType].
class InteractiveBox extends StatefulWidget {
  InteractiveBox({
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
      ControlActionType.none
    ],
    this.initialShowActionIcons = false,
    this.hideActionIconsWhenInteracting = true,
    this.circularMenuDegree,
    // this.circularMenuSpreadMultiplier = defaultSpreadDistanceMultiplier,
    this.showOverscaleBorder = false,
    this.overScaleBorderDecoration,
    this.defaultScaleBorderDecoration,
    this.iconSize = defaultIconSize,
    this.circularMenuIconColor = defaultMenuIconColor,
    this.copyIcon = const Icon(Icons.copy),
    this.scaleIcon = const Icon(Icons.zoom_out_map_outlined),
    this.rotateIcon = const Icon(Icons.rotate_right),
    this.deleteIcon = const Icon(Icons.delete),
    this.cancelIcon = const Icon(Icons.cancel),
    this.initialRotateAngle = 0.0,
    this.initialX = 0.0,
    this.initialY = 0.0,
    this.onActionSelected,
    this.scaleDotColor = defaultDotColor,
    this.overScaleDotColor = defaultOverscaleDotColor,
    // this.dot,
  })  : assert(includedActions.distinct().length == includedActions.length,
            "Duplicated items found in [includedAction] property."),
        super(key: key);

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

  /// A callback whenever an action (by pressing icon) is selected
  final ActionSelectedCallback? onActionSelected;

  final Color circularMenuIconColor;
  final double iconSize;
  final Widget copyIcon;
  final Widget scaleIcon;
  final Widget rotateIcon;
  final Widget deleteIcon;
  final Widget cancelIcon;

  final Color scaleDotColor;
  final Color overScaleDotColor;
  // final Widget? dot;

  @override
  InteractiveBoxState createState() => InteractiveBoxState();
}

class InteractiveBoxState extends State<InteractiveBox>
    with SingleTickerProviderStateMixin {
  late bool _showItems;
  late double _width;
  late double _height;

  bool _isPerforming = false;
  double _x = 0.0;
  double _y = 0.0;
  double _rotateAngle = 0.0;
  ControlActionType _selectedAction = ControlActionType.none;

  late AnimationController menuAnimationController;

  @override
  void initState() {
    super.initState();

    _showItems = widget.initialShowActionIcons;
    _x = widget.initialX;
    _y = widget.initialY;
    _width = widget.initialWidth;
    _height = widget.initialHeight;
    _rotateAngle = widget.initialRotateAngle;

    menuAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    if (_showItems) {
      menuAnimationController.forward();
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
        showOverScaleBorder: isOverScale,
        onAnyDotDraggingEnd: (details) {
          _onMovingEnd(details);
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
    }

    // Rotating
    if (widget.includedActions.contains(ControlActionType.rotate)) {
      child = RotatableItem(
        showRotatingIcon: isRotating,
        angle: _rotateAngle,
        onRotating: (details) {
          _onRotating(details);
        },
        onPanEnd: (details) {
          _onMovingEnd(details);
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
    child = SizedBox.expand(
      child: GestureDetector(
        onPanUpdate: (details) {
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
          setState(() {
            _showItems = !_showItems;
          });

          if (_showItems) {
            menuAnimationController.reverse();
          } else {
            menuAnimationController.forward();
          }
        },
        child: child,
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
        .where((element) => element != ControlActionType.move)
        .toList();

    return List.generate(
      unique.length,
      (index) {
        ControlActionType actionType = unique[index];

        Widget? icon;

        switch (actionType) {
          case ControlActionType.copy:
            icon = widget.copyIcon;
            break;
          case ControlActionType.scale:
            icon = widget.scaleIcon;
            break;
          case ControlActionType.rotate:
            icon = widget.rotateIcon;
            break;
          case ControlActionType.delete:
            icon = widget.deleteIcon;
            break;
          case ControlActionType.none:
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
            _toggleIsPerforming(true);
            setState(() {
              _selectedAction = actionType;
            });
            if (widget.onActionSelected != null) {
              widget.onActionSelected!(actionType);
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
    _toggleIsPerforming(false);
  }

  void _onMoving(DragUpdateDetails update) {
    // only moving when actiontype is none
    if (_selectedAction != ControlActionType.none) {
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
    switch (scaleDirection) {
      case ScaleDirection.centerLeft:
        double newWidth = updatedWidth - dx;

        updatedWidth = newWidth > 0 ? newWidth : 0;
        updatedXPosition += dx;

        break;

      case ScaleDirection.centerRight:
        double newWidth = updatedWidth + dx;
        updatedWidth = newWidth > 0 ? newWidth : 0;

        break;
      case ScaleDirection.topLeft:
        double mid = (dx + dy) / 2;

        double newHeight = updatedHeight - (2 * mid);
        double newWidth = updatedWidth - (2 * mid);

        updatedHeight = newHeight > 0 ? newHeight : 0;
        updatedWidth = newWidth > 0 ? newWidth : 0;
        updatedXPosition = updatedXPosition + mid;
        updatedYPosition = updatedYPosition + mid;

        break;

      case ScaleDirection.topCenter:
        double newHeight = updatedHeight -= dy;
        updatedHeight = newHeight > 0 ? newHeight : 0;
        updatedYPosition += dy;

        break;

      case ScaleDirection.topRight:
        double mid = (dx + (dy * -1)) / 2;

        double newHeight = updatedHeight + 2 * mid;
        double newWidth = updatedWidth + 2 * mid;

        updatedHeight = newHeight > 0 ? newHeight : 0;
        updatedWidth = newWidth > 0 ? newWidth : 0;
        updatedXPosition = updatedXPosition - mid;
        updatedYPosition = updatedYPosition - mid;

        break;

      case ScaleDirection.bottomLeft:
        double mid = ((dx * -1) + dy) / 2;

        double newHeight = updatedHeight + 2 * mid;
        double newWidth = updatedWidth + 2 * mid;

        updatedHeight = newHeight > 0 ? newHeight : 0;
        updatedWidth = newWidth > 0 ? newWidth : 0;
        updatedXPosition = updatedXPosition - mid;
        updatedYPosition = updatedYPosition - mid;

        break;
      case ScaleDirection.bottomCenter:
        double newHeight = updatedHeight + dy;
        updatedHeight = newHeight > 0 ? newHeight : 0;

        break;
      case ScaleDirection.bottomRight:
        double mid = (dx + dy) / 2;

        double newHeight = updatedHeight + 2 * mid;
        double newWidth = updatedWidth + 2 * mid;

        updatedHeight = newHeight > 0 ? newHeight : 0;
        updatedWidth = newWidth > 0 ? newWidth : 0;
        updatedXPosition = updatedXPosition - mid;
        updatedYPosition = updatedYPosition - mid;

        break;
      default:
    }

    if (_isWidthOverscale(updatedWidth)) {
      updatedXPosition = _x;
      updatedYPosition = _y;
      updatedWidth = widget.maxWidth!;
    }

    if (_isHeightOverscale(updatedHeight)) {
      updatedXPosition = _x;
      updatedYPosition = _y;
      updatedHeight = widget.maxHeight!;
    }

    // debugPrint("""
    //   x: $updatedXPosition,
    //   y: $updatedYPosition,
    //   w: $updatedWidth,
    //   h: $updatedHeight,
    //   dx: $dx,
    //   dy: $dy
    // """);

    setState(() {
      _width = updatedWidth;
      _height = updatedHeight;
      _x = updatedXPosition;
      _y = updatedYPosition;
    });
  }

  bool _isWidthOverscale(double width) {
    if (widget.maxWidth == null) return false;

    return width >= widget.maxWidth!;
  }

  bool _isHeightOverscale(double height) {
    if (widget.maxHeight == null) return false;

    return height >= widget.maxHeight!;
  }

  void _onRotating(DragUpdateDetails update) {
    // only update when actiontype is rotate
    if (_selectedAction != ControlActionType.rotate) {
      return;
    }

    _toggleIsPerforming(true);

    final touchedPosition = update.localPosition;

    // apply rotating logic
    setState(() {
      _rotateAngle = touchedPosition.direction;
    });
  }
}
