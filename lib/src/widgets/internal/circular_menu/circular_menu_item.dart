import 'package:flutter/material.dart';
import '../../../consts/circular_menu.const.dart';
import '../../../enums/control_action_type_enum.dart';

class CircularMenuItem extends StatelessWidget {
  const CircularMenuItem({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.actionType,
    required this.iconSize,
    this.iconColor = defaultMenuIconColor,
    this.backgroundColor = defaultMenuIconBgColor,
  });

  final ControlActionType actionType;
  final double iconSize;
  final Widget icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        fixedSize: Size(iconSize, iconSize),
        shape: const CircleBorder(),
        foregroundColor: iconColor,
        backgroundColor: backgroundColor,
      ),
      child: icon,
    );
  }
}
