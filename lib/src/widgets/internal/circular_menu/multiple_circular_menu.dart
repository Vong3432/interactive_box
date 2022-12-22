import 'dart:math';

import 'package:flutter/material.dart';
import '../../../consts/circular_menu.const.dart';

/// A widget that show circular menu
class MultipleCircularMenu extends StatefulWidget {
  const MultipleCircularMenu({
    super.key,
    required this.items,
    required this.child,
    required this.x,
    required this.y,
    required this.childWidth,
    required this.childHeight,
    required this.startFromDegree,
    this.showItems = false,
    this.iconSize = defaultIconSize,
    this.degree = defaultCircularMenuDegree,
    // this.spreadDistanceMultiplier = defaultSpreadDistanceMultiplier,
  }) :
        // TODO: Enhance the computation logic
        assert(
          items.length < 9,
          "Items length is too big, which will break the layout (overlapping).",
        );
  // assert(spreadDistanceMultiplier >= 0 && spreadDistanceMultiplier <= 1,
  //     "Spread distance multiplier can only between 0.0 and 1.0");

  final List<Widget> items;
  final bool showItems;
  final double x;
  final double y;
  final double childWidth;
  final double childHeight;
  final double iconSize;
  final double degree;
  final double startFromDegree;
  // final double spreadDistanceMultiplier;
  final Widget child;

  @override
  State<MultipleCircularMenu> createState() => _MultipleCircularMenuState();
}

class _MultipleCircularMenuState extends State<MultipleCircularMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController menuAnimationController;

  @override
  void initState() {
    super.initState();

    menuAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    if (widget.showItems) {
      menuAnimationController.forward();
    }
  }

  /// The controller state is controlled based on the class parameter, (i.e, [showItems]);
  ///
  /// Whenever [showItems] changes, this [didUpdateWidget] method will be called
  /// and run the animation to show/hide the circular menu items.
  ///
  /// ref: https://api.flutter.dev/flutter/animation/AnimationController-class.html
  ///
  @override
  void didUpdateWidget(covariant MultipleCircularMenu oldWidget) {
    if (widget.showItems != oldWidget.showItems) {
      super.didUpdateWidget(oldWidget);
      if (oldWidget.showItems) {
        menuAnimationController.reverse();
      } else {
        menuAnimationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.passthrough,
      children: [
        // Resize the child based on the width and height
        Positioned(
          left: widget.x,
          top: widget.y,
          width: widget.childWidth,
          height: widget.childHeight,
          child: widget.child,
        ),

        // Position the circular menu items
        Positioned(
          left: widget.x - (maxRadiusForCircularMenu / 2),
          top: widget.y - (maxRadiusForCircularMenu / 2),
          width: widget.childWidth + maxRadiusForCircularMenu,
          height: widget.childHeight + maxRadiusForCircularMenu,
          child: Flow(
            delegate: MultipleCircularMenuFlowDelegate(
              iconSize: widget.iconSize,
              menuAnimation: menuAnimationController,
              degree: widget.degree,
              startFromDegree: widget.startFromDegree,
              // spreadDistanceMultiplier: widget.spreadDistanceMultiplier,
            ),
            children: widget.items,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    menuAnimationController.dispose();
    super.dispose();
  }
}

class MultipleCircularMenuFlowDelegate extends FlowDelegate {
  const MultipleCircularMenuFlowDelegate({
    required this.menuAnimation,
    required this.degree,
    required this.startFromDegree,
    // required this.spreadDistanceMultiplier,
    required this.iconSize,
  }) : super(repaint: menuAnimation);

  final double iconSize;
  final double degree;
  final double startFromDegree;
  // final double spreadDistanceMultiplier;
  final Animation<double> menuAnimation;

  @override
  bool shouldRepaint(MultipleCircularMenuFlowDelegate oldDelegate) {
    return menuAnimation != oldDelegate.menuAnimation;
  }

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tight(Size(iconSize, iconSize));
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    // Dont paint if menu is not opened.
    if (menuAnimation.value == 0) return;

    /// Calculation formula below is referenced from:
    /// - https://github.com/toly1994328/ilayout/blob/master/lib/12/05/main.dart
    final int count = context.childCount;

    double radius = context.size.shortestSide / 2;
    if (radius > maxRadiusForCircularMenu) {
      radius = maxRadiusForCircularMenu;
    }

    final double degToRad = -degree * pi / 180;
    final double theta = degToRad / count;

    final Size centerPoint = Size(
      context.size.width / 2,
      context.size.height / 2,
    );
    final double centerX = centerPoint.width;
    final double centerY = centerPoint.height;

    for (int i = 0; i < count; i++) {
      final Size size = context.getChildSize(i) ?? Size.zero;
      final double angle = (startFromDegree * pi / 180) - i * theta;
      const double fixRotInRad = 90 * pi / 180;

      ///
      /// Calculate coordinate based on angle
      ///
      /// x = radius * cos(radian t) + h;
      /// y = radius * sin(radian t) + k;
      ///
      /// where h, k is center point of the circle
      ///
      final double offsetX = (radius - size.width) *
              cos(angle - fixRotInRad) *
              // spreadDistanceMultiplier *
              menuAnimation.value +
          centerX;
      final double offsetY = (radius - size.height) *
              sin(angle - fixRotInRad) *
              // spreadDistanceMultiplier *
              menuAnimation.value +
          centerY;

      context.paintChild(
        i,
        transform: Matrix4.translationValues(
          offsetX - size.width / 2,
          offsetY - size.height / 2,
          0.0,
        ),
        opacity: menuAnimation.value,
      );
    }
  }
}
