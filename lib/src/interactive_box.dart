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
      ControlActionType.none
    ],
    this.initialShowActionIcons = false,
    this.hideActionIconsWhenInteracting = true,
    this.circularMenuDegree,
    this.circularMenuSpreadMultiplier = defaultSpreadDistanceMultiplier,
    this.showOverscaleBorder = false,
    this.overScaleBorderDecoration,
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
    this.onRotating,
    this.onPanUpdate,
    this.onScaling,
    this.onPanEnd,
    this.scaleDotColor = defaultDotColor,
    this.overScaleDotColor = defaultOverscaleDotColor,
    // this.dot,
  }) : super(key: key);

  /// Whether the border should show a border when overscaled.
  final bool showOverscaleBorder;
  final Decoration? overScaleBorderDecoration;

  final bool initialShowActionIcons;

  /// Whether the action icons should be hidden when users interacting.
  ///
  /// Users-interactive actions:
  /// - [ControlActionType.rotate]
  /// - [ControlActionType.scale]
  /// - [ControlActionType.move]
  final bool hideActionIconsWhenInteracting;

  final double initialX;
  final double initialY;
  final double initialWidth;
  final double initialHeight;
  final double? maxWidth;
  final double? maxHeight;

  /// The rotate angle for [child].
  final double initialRotateAngle;

  /// Default will include all supported actions.
  final List<ControlActionType> includedActions;
  final Widget child;

  /// The required degree needed for the circular menu.
  final double? circularMenuDegree;

  /// Distance of the spread distance between the [child] and the circular menu.
  final double circularMenuSpreadMultiplier;

  /// A callback whenever an action (by pressing icon) is selected
  final ActionSelectedCallback? onActionSelected;
  final ScalingCallback? onScaling;
  final RotatingCallback? onRotating;

  /// A function that will be called when the [child] in property is being moved.
  ///
  /// The [DragUpdateDetails] object will also be affected if the [child] is rotated.
  final void Function(DragUpdateDetails)? onPanUpdate;

  /// A function that will be called when the [child] in property stop moving.
  final void Function(DragEndDetails)? onPanEnd;

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

    Widget child = widget.child;

    /// Build widget tree of [child] from the bottom to the top.
    ///
    /// Stack > Position > Rotate > Widget
    /// https://stackoverflow.com/a/67963491
    ///

    // Scaling
    if (widget.includedActions.contains(ControlActionType.scale)) {
      child = ScalableItem(
        // dot: widget.dot,
        scaleDotColor: widget.scaleDotColor,
        overScaleDotColor: widget.overScaleDotColor,
        overScaleBorderDecoration: widget.overScaleBorderDecoration,
        showOverScaleBorder: widget.showOverscaleBorder,
        onAnyDotDraggingEnd: (details) {
          _toggleIsPerforming(false);

          if (widget.onPanEnd != null) {
            widget.onPanEnd!(details);
          } else {
            _onMovingEnd(details);
          }
        },
        onTopLeftDotDragging: (details) {
          if (widget.onScaling != null) {
            widget.onScaling!(details, ScaleDirection.topLeft);
          } else {
            _onScaling(details, ScaleDirection.topLeft);
          }
          _toggleIsPerforming(true);
        },
        onTopCenterDotDragging: (details) {
          if (widget.onScaling != null) {
            widget.onScaling!(details, ScaleDirection.topCenter);
          } else {
            _onScaling(details, ScaleDirection.topCenter);
          }
          _toggleIsPerforming(true);
        },
        onTopRightDotDragging: (details) {
          if (widget.onScaling != null) {
            widget.onScaling!(details, ScaleDirection.topRight);
          } else {
            _onScaling(details, ScaleDirection.topRight);
          }
          _toggleIsPerforming(true);
        },
        onBottomLeftDotDragging: (details) {
          if (widget.onScaling != null) {
            widget.onScaling!(details, ScaleDirection.bottomLeft);
          } else {
            _onScaling(details, ScaleDirection.bottomLeft);
          }
          _toggleIsPerforming(true);
        },
        onBottomCenterDotDragging: (details) {
          if (widget.onScaling != null) {
            widget.onScaling!(details, ScaleDirection.bottomCenter);
          } else {
            _onScaling(details, ScaleDirection.bottomCenter);
          }
          _toggleIsPerforming(true);
        },
        onBottomRightDotDragging: (details) {
          if (widget.onScaling != null) {
            widget.onScaling!(details, ScaleDirection.bottomRight);
          } else {
            _onScaling(details, ScaleDirection.bottomRight);
          }
          _toggleIsPerforming(true);
        },
        onCenterLeftDotDragging: (details) {
          if (widget.onScaling != null) {
            widget.onScaling!(details, ScaleDirection.centerLeft);
          } else {
            _onScaling(details, ScaleDirection.centerLeft);
          }
          _toggleIsPerforming(true);
        },
        onCenterRightDotDragging: (details) {
          if (widget.onScaling != null) {
            widget.onScaling!(details, ScaleDirection.centerRight);
          } else {
            _onScaling(details, ScaleDirection.centerRight);
          }
          _toggleIsPerforming(true);
        },
        showDots: isScaling,
        child: child,
      );
    }

    child = MultipleCircularMenu(
      degree: widget.circularMenuDegree ?? defaultCircularMenuDegree,
      spreadDistanceMultiplier: widget.circularMenuSpreadMultiplier,
      iconSize: widget.iconSize,
      childWidth: _width,
      childHeight: _height,
      showItems: _showItems && !_isPerforming,
      items: _buildActionItems(),
      child: child,
    );

    // Rotating
    if (widget.includedActions.contains(ControlActionType.rotate)) {
      child = RotatableItem(
        showRotatingIcon: isRotating,
        angle: _rotateAngle,
        onRotating: (details) {
          if (widget.onRotating != null) {
            widget.onRotating!(details);
          } else {
            _onRotating(details);
          }
          _toggleIsPerforming(true);
        },
        onPanEnd: (details) {
          if (widget.onPanEnd != null) {
            widget.onPanEnd!(details);
          } else {
            _onMovingEnd(details);
          }
          _toggleIsPerforming(false);
        },
        child: child,
      );
    }

    /// Here is the topest in the widget tree of [child]
    child = Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.red,
      constraints: BoxConstraints.loose(
        /// Take the bigger size from width/height to handle rotation.
        ///
        /// By taking bigger size, we can make sure the [child] will always be inside of the "container" so that
        /// we can tap the buttons, dots around the [child].
        ///
        Size(
          // _width >= _height
          //     ? _width + (_width / 2) + widget.iconSize
          //     : _height + (_height / 2) + widget.iconSize,
          // _width >= _height
          //     ? _width + (_width / 2) + widget.iconSize
          //     : _height + (_height / 2) + widget.iconSize,
          _width + (_height) + widget.iconSize,
          _height + (_width) + widget.iconSize,
        ),
      ),
      transform: Matrix4.identity()
        ..translate(
          _x,
          _y,
        ),
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.passthrough,
        children: [
          GestureDetector(
            onPanUpdate: (details) {
              if (!widget.includedActions.contains(ControlActionType.move))
                return;

              if (widget.onPanUpdate != null) {
                widget.onPanUpdate!(details);
              } else {
                _onMoving(details);
              }

              _toggleIsPerforming(true);
            },
            onPanEnd: (details) {
              if (!widget.includedActions.contains(ControlActionType.move))
                return;

              if (widget.onPanEnd != null) {
                widget.onPanEnd!(details);
              } else {
                _onMovingEnd(details);
              }
              _toggleIsPerforming(false);
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
          Flow(
            delegate: MultipleCircularMenuFlowDelegate(
              iconSize: widget.iconSize,
              menuAnimation: menuAnimationController,
              containerWidth: _width,
              containerHeight: _height,
              degree: widget.circularMenuDegree ?? 0,
              spreadDistanceMultiplier: widget.circularMenuSpreadMultiplier,
            ),
            children: _buildActionItems(),
          ),
        ],
      ),
    );

    return child;
  }

  void _toggleIsPerforming(bool perform) {
    if (!perform) {
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
        .distinct()
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
  void _onMovingEnd(DragEndDetails details) {}

  void _onMoving(DragUpdateDetails update) {
    // only moving when actiontype is none
    if (_selectedAction != ControlActionType.none) {
      return;
    }

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

    double dx = update.delta.dx;
    double dy = update.delta.dy;

    double updatedWidth = _width;
    double updatedHeight = _height;
    double updatedXPosition = _x;
    double updatedYPosition = _y;

    /// Scale formula
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
        double newHeight = updatedHeight - dy;
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

    if (widget.maxWidth != null) {
      bool widthOverflow = updatedWidth >= widget.maxWidth!;

      if (widthOverflow) {
        updatedWidth = widthOverflow ? widget.maxWidth! : updatedWidth;
        updatedXPosition = _x;
        updatedYPosition = _y;
      }
    }

    if (widget.maxHeight != null) {
      bool heightOverflow = updatedHeight >= widget.maxHeight!;

      if (heightOverflow) {
        updatedHeight = heightOverflow ? widget.maxHeight! : updatedHeight;
        updatedXPosition = _x;
        updatedYPosition = _y;
      }
    }

    setState(() {
      _width = updatedWidth;
      _height = updatedHeight;
      _x = updatedXPosition;
      _y = updatedYPosition;
    });
  }

  void _onRotating(DragUpdateDetails update) {
    // only update when actiontype is rotate
    if (_selectedAction != ControlActionType.rotate) {
      return;
    }

    final touchedPosition = update.localPosition;

    // apply rotating logic
    setState(() {
      _rotateAngle = touchedPosition.direction;
    });
  }
}

/// TODO:
/// - Scaling
/// - Overscaled border
