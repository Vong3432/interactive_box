import 'dart:math';

import 'package:flutter/material.dart';
import '../../consts/circular_menu.const.dart';

/// A widget that show circular menu
class MultipleCircularMenu extends StatefulWidget {
  const MultipleCircularMenu({
    super.key,
    required this.items,
    required this.child,
    required this.childWidth,
    required this.childHeight,
    this.showItems = false,
    this.iconSize = defaultIconSize,
    this.degree = defaultCircularMenuDegree,
    this.spreadDistanceMultiplier = defaultSpreadDistanceMultiplier,
  })  :
        // TODO: Enhance the computation logic
        assert(
          items.length < 12,
          "Items length is too big, which will break the layout (overlapping).",
        ),
        assert(spreadDistanceMultiplier >= 0 && spreadDistanceMultiplier <= 1,
            "Spread distance multiplier can only between 0.0 and 1.0");

  final List<Widget> items;
  final bool showItems;
  final double childWidth;
  final double childHeight;
  final double iconSize;
  final double degree;
  final double spreadDistanceMultiplier;
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

  /// The duration of the controller is configured from a property, [initialShowActionIcons] in the MultipleCircularMenu widget;
  /// as that changes, the State.didUpdateWidget method is used to update the controller.
  ///
  /// Ref: https://api.flutter.dev/flutter/animation/AnimationController-class.html
  @override
  void didUpdateWidget(covariant MultipleCircularMenu oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showItems != oldWidget.showItems) {
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
          width: widget.childWidth,
          height: widget.childHeight,
          child: widget.child,
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
    required this.containerWidth,
    required this.containerHeight,
    required this.degree,
    required this.spreadDistanceMultiplier,
    required this.iconSize,
  }) : super(repaint: menuAnimation);

  final double containerWidth;
  final double containerHeight;
  final double iconSize;
  final double degree;
  final double spreadDistanceMultiplier;
  final Animation<double> menuAnimation;

  @override
  bool shouldRepaint(MultipleCircularMenuFlowDelegate oldDelegate) {
    return menuAnimation != oldDelegate.menuAnimation;
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(300, 300);
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

    // final double perRad = degree / 180 * pi / (count);
    // final double fixRotate = (degree / 2) / 180 * pi;

    final double radius = context.size.shortestSide / 2;
    final double degToRad = degree * pi / 180;
    final double theta = degToRad / count;

    final Size centerPoint = Size(
      context.size.width / 2,
      context.size.height / 2,
    );
    final double centerX = centerPoint.width;
    final double centerY = centerPoint.height;

    for (int i = 0; i < count; i++) {
      final Size size = context.getChildSize(i) ?? Size.zero;
      // final double fixRotate = (degree / 2) / 180 * pi;
      final double angle = i * theta;

      // final double offsetX = menuAnimation.value *
      //         spreadDistanceMultiplier *
      //         (radius - size.width / 2) *
      //         cos(perRad * i - fixRotate) +
      //     centerX;
      // final double offsetY = menuAnimation.value *
      //         spreadDistanceMultiplier *
      //         (radius - size.height / 2) *
      //         sin(perRad * i - fixRotate) +
      //     centerY;

      /// x = radius * cos(radian t) + h;
      /// y = radius * sin(radian t) + k;
      ///
      /// where h, k is center point of the circle
      final double offsetX = (radius - size.width / 2) *
              cos(angle) *
              spreadDistanceMultiplier *
              menuAnimation.value +
          centerX;
      final double offsetY = (radius - size.height / 2) *
              sin(angle) *
              spreadDistanceMultiplier *
              menuAnimation.value +
          centerY;

      // final double offsetX = menuAnimation.value *
      //         spreadDistanceMultiplier *
      //         (radius - size.width / 2) *
      //         cos(i * perRad - fixRotate) +
      //     radius;
      // final double offsetY = menuAnimation.value *
      //         spreadDistanceMultiplier *
      //         (radius - size.height / 2) *
      //         sin(i * perRad - fixRotate) +
      //     radius;

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
