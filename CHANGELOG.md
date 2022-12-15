# Changelog
This changelog uses [semantic versioning](https://semver.org) for documenting changes. 

## 0.3.2
[Changed]
- Now the `InteractiveBox` can be rotated by the rotation indicator.

[Added]
- Add `defer_pointer` dependency. 


## 0.3.1
[Breaking changes]
- Adds onMenuToggled callback, previously onTap is acting like a callback whenever menu is toggled.. 
- Can now use callbacks for [ToggleActionType](lib/src/enums/toggle_action_type.enum.dart) like how it is in GestureDetector.
- ⚠️ Might experience some slow respond whenever menu is toggled. Especially when [toggleBy] is set as [ToggleActionType.onTap].

## 0.3.0
#### InteractiveBox
[Fix]
- Fix scale border decoration causing the [child]/[shape] slightly be pushed from its correct position.
- Scale border will now only be showed during scaling. Previously the border will be shown although not performing scaling.

[Changed]
- Refactor parameters that related to width, height, x, y with Size() and Offset().

[Added]
- Adds ability to toggle menu with different gestures instead of onTap (default behavior) only. 

    The supported gestures are:
    - onTap
    - onDoubleTap
    - onSecondaryTap
    - onLongPress

    For more details, refer to [here](lib/src/enums/toggle_action_type.enum.dart)

- Adds ability to use shape without passing [child] widget. This could be useful when you want to show a simple shapes.

    The supported shapes are:
    - Oval
    - Circle
    - Rectangle

    For more details, refer to [here](lib/src/enums/shape_enum.dart)
#### docs
- Updates example code.

## 0.2.5
#### InteractiveBox 
- Adds ability to use only specific scale directions
- Fixes effects not applying if includedActions does not contain the relevant actions.

#### docs
- Updates readme for example.

## 0.2.4
#### InteractiveBox 
- Fixes incorrect scaling after rotating.
- Adds new OnInteractiveActionPerforming handler.
- Will now respond and set all initial properties (e.g: initialX, initialY, ...) from parameters to state if they changes.

## 0.2.3
#### InteractiveBox 
- Will now respond and set [initialShowActionIcons] from parameters to state if it changes.
- Fixes menu not toggled correctly after copying.   
    - Previously if we toggle an InteractiveBox, let it be I1 (I1's menu is opened) and perform "COPY", I1's menu will be closed. But when we try to toggle I1 again, the menu does not open as we expected.
#### docs
- Updates example code.
    -  Replace key (previously ObjectKey) to ValueKey so that menu will not be retoggled when [hideActionIconsWhenInteracting] is false.

## 0.2.2
#### InteractiveBox 
- Adds RepaintBoundary to prevent unncessary repaint in large list.

## 0.2.1
#### InteractiveBox 
- Makes the interactive box update when needed.

## 0.2.0
#### InteractiveBox 
- Add new onInteractiveActionPerformed handler
- Add onTap handler for interactive box

#### Other
- Fix moving not setting action type to move

#### docs
- Update example

## 0.1.0
#### InteractiveBox 
- Fixes interactive box not using initial rotate angle
- Adds new parameter in ```onActionSelected()``` to get a ``InteractiveBox``'s info for copy

#### docs
- Update changelog and example code

## 0.0.1

- Initial release
