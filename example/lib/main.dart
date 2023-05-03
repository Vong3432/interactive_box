import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:interactive_box/interactive_box.dart';
import 'package:uuid/uuid.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MyHomePage(
      title: "title",
      size: MediaQuery.of(context).size,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.size});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final Size size;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TransformationController _controller;
  // Just a sample, you may use your own List.
  List<TableModel> tables = [];
  double _top = 0.0;
  double _left = 0.0;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController()
      ..addListener(() {
        final scale = _controller.value.getMaxScaleOnAxis() - 1 > 0
            ? _controller.value.getMaxScaleOnAxis()
            : 1.0;
        debugPrint(scale.toString());
        setState(() {
          _top = 10 * scale;
          _left = 10 * scale;
          _scale = scale - 1;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        tables.add(
                          TableModel(
                            id: const Uuid().v4(),
                            showIcons: false,
                            width: 300,
                            height: 300,
                            x: 0,
                            y: 0,
                            rotateAngle: 0,
                            image: Image.asset(
                              "assets/table.png",
                              fit: BoxFit.fill,
                            ),
                          ),
                        );
                      });
                    },
                    child: const Text("Import"),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints.loose(
                  Size(
                    screenSize.width,
                    screenSize.height,
                  ),
                ),

                ///
                /// Create infinite screen.
                /// ref: https://stackoverflow.com/a/70915030
                ///
                /// Author: @Tor-Martin Holen
                ///
                child: InteractiveViewer.builder(
                  transformationController: _controller,
                  builder: (context, quad) {
                    return Center(
                      child: SizedBox(
                        width: screenSize.width,
                        height: screenSize.height,
                        child: GridPaper(
                          child: Stack(
                            children: [
                              ...List.generate(100, (index) {
                                return Positioned(
                                  top: 100 + _top,
                                  left: 100 + _left,
                                  child: GestureDetector(
                                    onPanUpdate: (details) {
                                      debugPrint("UPDATe");
                                      setState(() {
                                        _left = details.delta.dx;
                                        _top = details.delta.dy;
                                      });
                                    },
                                    child: Transform.scale(
                                      scale: _scale > 0 ? _scale : 0.1,
                                      child: CustomPaint(
                                        painter: CircleShapePainter(
                                          radius: 50,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              })
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Content extends StatelessWidget {
  const Content({
    super.key,
    required this.tables,
    required this.onAdd,
    required this.onUpdate,
    required this.onToggle,
    required this.onDel,
  });

  final List<TableModel> tables;
  final void Function(TableModel table) onAdd;
  final void Function(TableModel table, int index) onUpdate;
  final void Function(TableModel table, int index) onToggle;
  final void Function(int index) onDel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: [
        ...List.generate(tables.length, (index) {
          TableModel table = tables[index];
          return InteractiveBox(
            key: ValueKey(table.id),
            defaultScaleBorderDecoration: BoxDecoration(
              border: Border.all(
                width: 5,
                color: Colors.grey,
              ),
            ),
            // hideActionIconsWhenInteracting: false,
            startFromDegree: -45,
            initialSize: Size(table.width, table.height),
            initialShowActionIcons: table.showIcons,
            initialPosition: Offset(table.x, table.y),
            initialRotateAngle: table.rotateAngle,
            circularMenuDegree: 180,
            iconSize: 40,
            toggleBy: ToggleActionType.onTap,
            onInteractiveActionPerforming: (_, __, details) {
              debugPrint("Drag update details: $details");
            },
            onInteractiveActionPerformed: (_, boxInfo, __) {
              /// Copy boxInfo and update to table after performing interactive actions
              /// so that when we toggle the icons in [onTap] method below, all tables
              /// will be updated correctly (persist their position, size, rotate angle)...
              ///
              ///
              /// Without this you might see the other tables not updated correctly.
              /// To demo this problem,
              /// 1. Comment the code below
              /// 2. Press "import" button twice
              /// 3. Drag the second image to another side
              /// 4. Tap the first image
              ///
              /// and you will see the second image is jumped to its original position.
              ///

              // START comment here if want to see the problem
              TableModel copiedTable = table.copyWith(
                width: boxInfo.size.width,
                height: boxInfo.size.height,
                rotateAngle: boxInfo.rotateAngle,
                x: boxInfo.position.dx,
                y: boxInfo.position.dy,
              );

              onUpdate(copiedTable, index);

              // END comment here if want to see the problem
            },
            onMenuToggled: (boxInfo) {
              ///
              /// Might refer to [onInteractiveActionPerformed]
              ///
              // setState(() {
              TableModel copiedTable = table.copyWith(
                showIcons: !table.showIcons,
              );

              onToggle(copiedTable, index);
            },
            onTap: () => {debugPrint("ON TAPPED")},
            onDoubleTap: () => {debugPrint("ON DOUBLE TAPPED")},
            onLongPress: () => {debugPrint("ON LONG PRESS")},
            onSecondaryTap: () => {debugPrint("ON SECONDARY TAP")},
            onActionSelected: (actionType, boxInfo) {
              if (actionType == ControlActionType.copy) {
                TableModel copiedTable = table.copyWith(
                  id: const Uuid().v4(),
                  width: boxInfo.size.width,
                  height: boxInfo.size.height,
                  rotateAngle: boxInfo.rotateAngle,
                  showIcons: false,
                  x: boxInfo.position.dx + 50,
                  y: boxInfo.position.dy + 50,
                );

                onToggle(table.copyWith(showIcons: !table.showIcons), index);
                onAdd(copiedTable);
              } else if (actionType == ControlActionType.delete) {
                onDel(index);
              }
            },
            includedActions: const [
              ControlActionType.copy,
              ControlActionType.delete,
              ControlActionType.move,
              ControlActionType.rotate,
              ControlActionType.scale,
            ],
            maxSize: const Size(300, 300),
            shape: Shape.oval,
            shapeStyle: ShapeStyle(
              borderWidth: 5,
              borderColor: Colors.red[200],
              backgroundColor: Colors.red,
            ),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: tables[index].image,
              ),
            ),
          );
        })
      ],
    );
  }
}

@immutable
class TableModel {
  final String id;
  final double width;
  final double height;
  final double x;
  final double y;
  final double rotateAngle;
  final bool showIcons;
  final Widget image;

  const TableModel({
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    required this.rotateAngle,
    required this.image,
    required this.id,
    required this.showIcons,
  });

  TableModel copyWith({
    String? id,
    double? width,
    double? height,
    double? x,
    double? y,
    double? rotateAngle,
    Widget? image,
    bool? showIcons,
  }) {
    return TableModel(
      id: id ?? this.id,
      showIcons: showIcons ?? this.showIcons,
      width: width ?? this.width,
      height: height ?? this.height,
      x: x ?? this.x,
      y: y ?? this.y,
      rotateAngle: rotateAngle ?? this.rotateAngle,
      image: image ?? this.image,
    );
  }
}

class CircleShape extends StatelessWidget {
  const CircleShape({
    super.key,
    required this.radius,
    this.style,
    this.child,
  });

  final double radius;
  final ShapeStyle? style;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CircleShapePainter(
        radius: radius,
        style: style,
      ),
      child: child,
    );
  }
}

class CircleShapePainter extends CustomPainter {
  final double radius;
  final ShapeStyle? style;

  CircleShapePainter({
    required this.radius,
    this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double borderWidth = 2.0;
    final paint = Paint()
      ..strokeWidth = borderWidth
      ..color = Colors.red
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(
        radius,
        radius,
      ),
      radius,
      fillPaint,
    );

    canvas.drawCircle(
      Offset(
        radius,
        radius,
      ),
      radius,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CircleShapePainter oldDelegate) {
    return oldDelegate.style != style || oldDelegate.radius != radius;
  }
}
