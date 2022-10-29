# Changelog
This changelog uses [semantic versioning](https://semver.org) for documenting changes. 
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
