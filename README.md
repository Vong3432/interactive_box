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

![demo](https://raw.githubusercontent.com/Vong3432/interactive_box/main/demo/interactive_box_demo.gif)

## Usage

### Simple use
```dart
Stack(
  children: [
    InteractiveBox(
      initialSize: Size(300, 300), // required

      /*  If you want to show a widget */
      child: Image.asset(
        "assets/table.png",
        fit: BoxFit.fill,
      ), 

      /**
        If you want to show a shape instead of a widget, please refers to [Customize shape] in this README file below.

        Note: Both [shape] and [child] cannot be included together.
       */
    )
  ]
)

```

### Set initial position
```dart
InteractiveBox(
      // properties from simple use
      ...,
      initialPosition: Offset(100, 100),
      initialRotateAngle: 45, 
)
```

### Only use specific actions
Default will use all available actions, refers to [ControlActionType](lib/src/enums/control_action_type_enum.dart)
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

### Customize shape (when ``shape`` is provided)
Refers to [Shape](lib/src/enums/shape_enum.dart) for more shapes.
```dart
InteractiveBox(
      // properties from simple use
      ...,
      shape: Shape.oval,
      shapeStyle: const ShapeStyle(
        borderWidth: 5,
        borderColor: Colors.red,
        backgroundColor: Colors.black,
      ),
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

      // only use specific scale directions
      includedScaleDirections: const [
        ScaleDirection.topCenter,
        ScaleDirection.bottomCenter,
        ScaleDirection.topRight,
      ],

      // borders
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
