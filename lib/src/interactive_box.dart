import 'package:flutter/material.dart';
import 'package:interactive_box/src/widgets/internal/shapes/circle_shape.dart';
import 'package:interactive_box/src/widgets/internal/shapes/oval_shape.dart';

import 'enums/control_action_type_enum.dart';
import 'enums/scale_direction_enum.dart';
import 'enums/shape_enum.dart';
import 'enums/toggle_action_type.enum.dart';
import 'helpers/scale_helper.dart';
import 'models/interactive_box_info.dart';
import 'models/scale_info.dart';
import 'models/shape_style.dart';
import 'typedef.dart';
import 'consts/scale_item.const.dart';
import 'consts/circular_menu.const.dart';
import 'widgets/internal/circular_menu/circular_menu_item.dart';
import 'widgets/internal/circular_menu/multiple_circular_menu.dart';
import 'widgets/internal/rotatable_item.dart';
import 'widgets/internal/scalable_item.dart';
import 'widgets/internal/shapes/rectangle_shape.dart';

/// A widget that supports controllable actions from [ControlActionType].
class InteractiveBox extends StatefulWidget {
  const InteractiveBox({
    Key? key,
    this.child,
    this.shape,
    required this.initialSize,
    this.maxSize,
    this.includedActions = const [
      ControlActionType.copy,
      ControlActionType.delete,
      ControlActionType.rotate,
      ControlActionType.scale,
      ControlActionType.move,
      ControlActionType.none
    ],
    this.initialShowActionIcons = false,
    this.toggleBy = ToggleActionType.onTap,
    this.hideActionIconsWhenInteracting = true,
    this.circularMenuDegree,
    this.startFromDegree = 0,
    // this.circularMenuSpreadMultiplier = defaultSpreadDistanceMultiplier,
    this.showOverscaleBorder = true,
    this.overScaleBorderDecoration,
    this.defaultScaleBorderDecoration,
    this.shapeStyle,
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
    this.initialPosition = const Offset(0.0, 0.0),
    this.onActionSelected,
    this.onInteractiveActionPerforming,
    this.onInteractiveActionPerformed,
    this.scaleDotColor = defaultDotColor,
    this.overScaleDotColor = defaultOverscaleDotColor,
    this.includedScaleDirections,
    this.onMenuToggled,
    this.onTap,
    this.onDoubleTap,
    this.onSecondaryTap,
    this.onLongPress,
    // this.dot,
  })  : assert(child != null || shape != null,
            "Either child or shape must be provided."),
        // assert(child != null && shape == null || shape != null && child == null,
        //     "Only can provide either child or shape."),
        assert(shape == Shape.circle ? includedScaleDirections == null : true,
            "When [shape] is circle, no need pass [includedScaleDirections] since they will be overwritted."),
        super(key: key);

  /// Whether the border should show a border when overscaled.
  final bool showOverscaleBorder;
  final Decoration? overScaleBorderDecoration;

  /// Default decoration for scale border
  final Decoration? defaultScaleBorderDecoration;

  final bool initialShowActionIcons;

  final ToggleActionType? toggleBy;

  /// Whether the action icons should be hidden when users interacting.
  ///
  /// Users-interactive actions:
  /// - [ControlActionType.rotate]
  /// - [ControlActionType.scale]
  /// - [ControlActionType.move]
  ///
  final bool hideActionIconsWhenInteracting;

  final Offset initialPosition;
  final Size initialSize;

  /// The maximum size that the [child] can be scaled
  final Size? maxSize;

  /// The rotate angle for [child] in radian.
  final double initialRotateAngle;

  /// Default will include all supported actions.
  final List<ControlActionType> includedActions;

  /// A canvas that will be drawn based on the shape.
  final Shape? shape;
  final Widget? child;

  /// The full degree wanted for the circular menu.
  final double? circularMenuDegree;

  /// The degree of which first action item will be generated until the [circularMenuDegree] in clockwise.
  final double startFromDegree;

  // Distance of the spread distance between the [child] and the circular menu.
  // final double circularMenuSpreadMultiplier;

  /// A callback that will be called whenever an action (by pressing icon) is selected
  final ActionSelectedCallback? onActionSelected;

  /// A callback that will be called when performing interactive actions.
  final OnInteractiveActionPerforming? onInteractiveActionPerforming;

  /// A callback that will be called after performing interactive actions.
  final OnInteractiveActionPerformed? onInteractiveActionPerformed;

  final OnMenuToggleCallback? onMenuToggled;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onSecondaryTap;
  final VoidCallback? onLongPress;

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

  /// The scale directions you want to support.
  ///
  /// Default will included all directions for [shape] that are not [Shape.circle].
  ///
  /// Warning:
  /// - Do note that when [shape] is [Shape.circle], includes this param will throw an exception
  ///   since this param will be overwritted even you pass a different directions with:
  ///   - [ScaleDirection.topLeft]
  ///   - [ScaleDirection.topRight]
  ///   - [ScaleDirection.bottomLeft]
  ///   - [ScaleDirection.bottomRight]
  ///
  ///
  final List<ScaleDirection>? includedScaleDirections;

  /// The style configuration to apply for [shape].
  final ShapeStyle? shapeStyle;

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
    _x = widget.initialPosition.dx;
    _y = widget.initialPosition.dy;
    _width = widget.initialSize.width;
    _height = widget.initialSize.height;
    _rotateAngle = widget.initialRotateAngle;
  }

  @override
  void didUpdateWidget(InteractiveBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialShowActionIcons != widget.initialShowActionIcons) {
      _showItems = widget.initialShowActionIcons;
    }
    if (oldWidget.initialSize.width != widget.initialSize.width) {
      _width = widget.initialSize.width;
    }
    if (oldWidget.initialSize.height != widget.initialSize.height) {
      _height = widget.initialSize.height;
    }
    if (oldWidget.initialPosition.dx != widget.initialPosition.dx) {
      _x = widget.initialPosition.dx;
    }
    if (oldWidget.initialPosition.dy != widget.initialPosition.dy) {
      _y = widget.initialPosition.dy;
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

    Widget child = Container();

    if (widget.child != null) {
      child = widget.child!;
    }

    switch (widget.shape) {
      case Shape.circle:
        child = CircleShape(
          radius: _width / 2,
          style: widget.shapeStyle,
          child: child,
        );
        break;
      case Shape.oval:
        child = OvalShape(
          width: _width,
          height: _height,
          style: widget.shapeStyle,
          child: child,
        );
        break;
      case Shape.rectangle:
        child = RectangleShape(
          width: _width,
          height: _height,
          style: widget.shapeStyle,
          child: child,
        );
        break;
      default:
        break;
    }

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
    child = ScalableItem(
      // dot: widget.dot,
      cornerDotColor: widget.scaleDotColor,
      overScaleCornerDotColor: widget.overScaleDotColor,
      overScaleBorderDecoration: widget.overScaleBorderDecoration,
      defaultScaleBorderDecoration: widget.defaultScaleBorderDecoration,
      showOverScaleBorder: isOverScale && widget.showOverscaleBorder,
      isScaling: isScaling,
      includedScaleDirections: widget.shape == Shape.circle
          ? const [
              ScaleDirection.topLeft,
              ScaleDirection.topRight,
              ScaleDirection.bottomRight,
              ScaleDirection.bottomLeft,
            ]
          : widget.includedScaleDirections == null
              ? const [
                  ScaleDirection.topLeft,
                  ScaleDirection.topCenter,
                  ScaleDirection.topRight,
                  ScaleDirection.centerRight,
                  ScaleDirection.bottomRight,
                  ScaleDirection.bottomCenter,
                  ScaleDirection.bottomLeft,
                  ScaleDirection.centerLeft,
                ]
              : widget.includedScaleDirections!,
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

    // Rotating
    child = RotatableItem(
      rotateIndicatorSpacing: widget.rotateIndicatorSpacing,
      rotateIndicator: widget.rotateIndicator,
      showRotatingIcon: isRotating,
      initialRotateAngle: widget.initialRotateAngle,
      onRotating: (details, rotateAngle) {
        _rotateAngle = rotateAngle;
        _notifyParentWhenInteracting(details);
        _toggleIsPerforming(true);
      },
      onRotatingEnd: (details, finalAngle) {
        _rotateAngle = finalAngle;
        _notifyParentAfterInteracted(details);
        _toggleIsPerforming(false);
      },
      child: child,
    );

    child = MultipleCircularMenu(
      x: _x,
      y: _y,
      degree: widget.circularMenuDegree ?? defaultCircularMenuDegree,
      startFromDegree: widget.startFromDegree,
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
          onDoubleTap: () {
            if (widget.onDoubleTap != null) {
              widget.onDoubleTap!();
            }
            _toggleMenu(ToggleActionType.onDoubleTap);
          },
          onSecondaryTap: () {
            if (widget.onSecondaryTap != null) {
              widget.onSecondaryTap!();
            }
            _toggleMenu(ToggleActionType.onSecondaryTap);
          },
          onLongPress: () {
            if (widget.onLongPress != null) {
              widget.onLongPress!();
            }
            _toggleMenu(ToggleActionType.onLongPress);
          },
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!();
            }
            _toggleMenu(ToggleActionType.onTap);
          },
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
          child: child,
        ),
      ),
    );

    return child;
  }

  bool _shouldThisGestureToggleActions(ToggleActionType toggleActionType) {
    return toggleActionType == widget.toggleBy;
  }

  void _toggleMenu(ToggleActionType toggleActionType) {
    if (!_shouldThisGestureToggleActions(toggleActionType)) return;

    setState(() {
      _showItems = !_showItems;
    });

    if (widget.onMenuToggled != null) {
      widget.onMenuToggled!(_getCurrentBoxInfo);
    }
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
    _notifyParentAfterInteracted(details);
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

    _notifyParentWhenInteracting(update);
  }

  void _onScalingEnd(DragEndDetails details) {
    // only update when actiontype is scaling
    if (_selectedAction != ControlActionType.scale) {
      return;
    }

    _notifyParentAfterInteracted(details);
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

    final ScaleInfo current = ScaleInfo(
      width: _width,
      height: _height,
      x: _x,
      y: _y,
    );
    final double dx = update.delta.dx;
    final double dy = update.delta.dy;
    final ScaleInfoOpt scaleInfoOpt = ScaleInfoOpt(
      shape: widget.shape ?? Shape.rectangle,
      scaleDirection: scaleDirection,
      dx: dx,
      dy: dy,
      rotateAngle: _rotateAngle,
    );

    final ScaleInfo scaleInfoAfterCalculation = ScaleHelper.getScaleInfo(
      current: current,
      options: scaleInfoOpt,
    );
    double updatedWidth = scaleInfoAfterCalculation.width;
    double updatedHeight = scaleInfoAfterCalculation.height;
    double updatedXPosition = scaleInfoAfterCalculation.x;
    double updatedYPosition = scaleInfoAfterCalculation.y;

    if (_isWidthOverscale(updatedWidth)) {
      updatedXPosition = _x;
      updatedWidth = widget.maxSize!.width;
    }

    if (_isHeightOverscale(updatedHeight)) {
      updatedYPosition = _y;
      updatedHeight = widget.maxSize!.height;
    }

    setState(() {
      _width = updatedWidth;
      _height = updatedHeight;
      _x = updatedXPosition;
      _y = updatedYPosition;
    });

    _notifyParentWhenInteracting(update);
  }

  bool _isWidthOverscale(double width) {
    if (widget.maxSize?.width == null) return false;

    return width >= widget.maxSize!.width;
  }

  bool _isHeightOverscale(double height) {
    if (widget.maxSize?.height == null) return false;

    return height >= widget.maxSize!.height;
  }

  InteractiveBoxInfo get _getCurrentBoxInfo => InteractiveBoxInfo(
        size: Size(_width, _height),
        position: Offset(_x, _y),
        rotateAngle: _rotateAngle,
      );

  final List<ControlActionType> _interactiveActions = [
    ControlActionType.move,
    ControlActionType.scale,
    ControlActionType.rotate,
  ];

  void _notifyParentWhenInteracting(DragUpdateDetails details) {
    if (!_interactiveActions.contains(_selectedAction)) return;

    if (widget.onInteractiveActionPerforming != null) {
      widget.onInteractiveActionPerforming!(
          _selectedAction, _getCurrentBoxInfo, details);
    }
  }

  void _notifyParentAfterInteracted(DragEndDetails details) {
    if (!_interactiveActions.contains(_selectedAction)) return;

    if (widget.onInteractiveActionPerformed != null) {
      widget.onInteractiveActionPerformed!(
          _selectedAction, _getCurrentBoxInfo, details);
    }
  }
}
