import 'package:flutter/material.dart';

import 'enums/control_action_type_enum.dart';
import 'enums/scale_direction_enum.dart';

typedef ActionSelectedCallback = void Function(ControlActionType);
typedef ScalingCallback = void Function(DragUpdateDetails, ScaleDirection);
typedef RotatingCallback = void Function(DragUpdateDetails);
