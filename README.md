<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# interactive_box

A Flutter widget that has pre-defined design for scaling, rotating, moving interaction. 

The main idea of this widget is to allow integrating interactive features (e.g: scaling, rotate, move, copy, ...) without the need to DIY the widget by yourself. Developers can also implement the custom logic to handle the `InteractiveBox` widget.
## Usage

### Simple use
```dart
Stack: (
  children: [
    InteractiveBox(
      initialWidth: width, // required
      initialHeight: height, // required
      initialX: xPosition, // required
      initialY: yPosition, // required
      initialRotateAngle: rotate, // required
      child: Image.asset(
        "assets/table.png",
        fit: BoxFit.fill,
      ), // required
    )
  ]
)

```

### Only use specific actions
```dart
InteractiveBox(
      // properties from simple use
      ...,
      includedActions: const [
        ControlActionType.copy,
        ControlActionType.move,
      ],
)
```

### Customize circular menu
```dart
InteractiveBox(
      // properties from simple use
      ...,
      circularMenuDegree: 360,
      circularMenuIconColor: Colors.green,

      // Set to true if you want to hide the menu items when performing interactive actions.
      hideActionIconsWhenInteracting: true,

      // icon size for menu items
      iconSize: 40, 

      // custom icons
      copyIcon: Icon(Icons.abc),
      scaleIcon: Icon(Icons.abc),
      rotateIcon: Icon(Icons.abc),
      deleteIcon: Icon(Icons.abc),
      cancelIcon: Icon(Icons.abc),
)
```
### Customize scale border
```dart
InteractiveBox(
      // properties from simple use
      ...,
      scaleDotColor: Colors.purple[600]!,
      overScaleDotColor: Colors.red[400]!,
      defaultScaleBorderDecoration: BoxDecoration(
        border: Border.all(
          width: 5,
          color: Colors.purple[700]!,
        ),
        shape: BoxShape.rectangle,
      ),
      overScaleBorderDecoration: BoxDecoration(
        border: Border.all(
          width: 5,
          color: Colors.red[700]!,
        ),
        shape: BoxShape.rectangle,
      ),

      // Set to true if you want to show overscale border when both width and height is equal to maxWidth and maxHeight
      maxWidth: 300,
      maxHeight: 300,
      showOverscaleBorder: true,
)
```

### Customize rotate indicator
```dart
InteractiveBox(
      // properties from simple use
      ...,
      rotateIndicator: const Icon(Icons.abc),
      rotateIndicatorSpacing: 50,
)
```
