import 'package:flutter/material.dart';
import 'package:interactive_box/interactive_box.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: "title"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TransformationController _controller;
  // Just a sample, you may use your own List.
  List<TableModel> tables = [];

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();

    List<TableModel> dumData = List.generate(
      10,
      (_) => TableModel(
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

    setState(() {
      tables.addAll(dumData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    debugPrint("Rebuild home");
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(18),
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
                        child: Content(tables: tables),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Table extends StatelessWidget {
  const Table({
    super.key,
    required this.idx,
    required this.table,
    required this.onAdded,
    required this.onToggled,
    required this.onDeleted,
    required this.onUpdated,
  });

  final TableModel table;
  final int idx;
  final void Function(TableModel, int) onUpdated;
  final void Function(TableModel, int) onToggled;
  final void Function(int) onDeleted;
  final void Function(TableModel) onAdded;

  @override
  Widget build(BuildContext context) {
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
        debugPrint("Box info: $boxInfo");
      },
      onMenuToggled: (boxInfo) {
        debugPrint("Toggled menu");
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

          onToggled(table.copyWith(showIcons: !table.showIcons), idx);
          onAdded(copiedTable);
        } else if (actionType == ControlActionType.delete) {
          onDeleted(idx);
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
          child: table.image,
        ),
      ),
    );
  }
}

class Content extends StatefulWidget {
  const Content({
    super.key,
    required this.tables,
  });

  final List<TableModel> tables;

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  List<TableModel> tables = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      tables = widget.tables;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: [
        ...List.generate(widget.tables.length, (index) {
          TableModel table = widget.tables[index];
          return Table(
            key: ValueKey(table.id),
            idx: index,
            table: table,
            onAdded: (table) {
              setState(() {
                tables.add(table);
              });
            },
            onDeleted: (index) {
              setState(() {
                tables.removeAt(index);
              });
            },
            onToggled: (tappedTable, idx) {
              setState(() {
                tables[index] = tappedTable;
              });

              for (TableModel table in tables) {
                int index = tables.indexOf(table);

                if (index == -1) return;

                if (table.id != tappedTable.id && table.showIcons == true) {
                  setState(() {
                    tables[index] = table.copyWith(showIcons: false);
                  });
                }
              }
            },
            onUpdated: (table, index) {
              setState(() {
                tables[index] = table;
              });
            },
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
