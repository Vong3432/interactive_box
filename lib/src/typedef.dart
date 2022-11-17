import 'package:flutter/material.dart';

import 'models/interactive_box_info.dart';
import 'enums/control_action_type_enum.dart';

typedef ActionSelectedCallback = void Function(
    ControlActionType, InteractiveBoxInfo);
typedef OnInteractiveActionPerformed = void Function(
    ControlActionType, InteractiveBoxInfo, DragEndDetails);
typedef OnInteractiveActionPerforming = void Function(
    ControlActionType, InteractiveBoxInfo, DragUpdateDetails);

typedef OnMenuToggleCallback = void Function(InteractiveBoxInfo);
// typedef ScalingCallback = void Function(DragUpdateDetails, ScaleDirection);
// typedef RotatingCallback = void Function(DragUpdateDetails);
