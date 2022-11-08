import 'models/interactive_box_info.dart';
import 'enums/control_action_type_enum.dart';

typedef ActionSelectedCallback = void Function(
    ControlActionType, InteractiveBoxInfo);
typedef OnInteractiveActionPerformed = void Function(
    ControlActionType, InteractiveBoxInfo);
typedef OnInteractiveActionPerforming = void Function(
    ControlActionType, InteractiveBoxInfo);
typedef OnTapCallback = void Function(InteractiveBoxInfo);
typedef OnDoubleTapCallback = void Function(InteractiveBoxInfo);
typedef OnSecondaryTapCallback = void Function(InteractiveBoxInfo);
typedef OnLongPressCallback = void Function(InteractiveBoxInfo);
typedef OnForcePressCallback = void Function(InteractiveBoxInfo);
// typedef ScalingCallback = void Function(DragUpdateDetails, ScaleDirection);
// typedef RotatingCallback = void Function(DragUpdateDetails);
