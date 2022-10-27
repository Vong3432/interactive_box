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
      1000,
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

    return Container(
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
                        child: Content(
                            tables: tables,
                            onAdd: (TableModel table) {
                              setState(() {
                                tables.add(table);
                              });
                            },
                            onToggle: (tappedTable, index) {
                              setState(() {
                                tables[index] = tappedTable;
                              });

                              for (TableModel table in tables) {
                                int index = tables.indexOf(table);

                                if (index == -1) return;

                                if (table.id != tappedTable.id &&
                                    table.showIcons == true) {
                                  setState(() {
                                    tables[index] =
                                        table.copyWith(showIcons: false);
                                  });
                                }
                              }
                            },
                            onUpdate: (TableModel table, int index) {
                              setState(() {
                                tables[index] = table;
                              });
                            },
                            onDel: (int index) {
                              setState(() {
                                tables.removeAt(index);
                              });
                            }),
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
            key: ObjectKey(table),
            initialWidth: table.width,
            initialHeight: table.height,
            initialShowActionIcons: table.showIcons,
            initialX: table.x,
            initialY: table.y,
            initialRotateAngle: table.rotateAngle,
            circularMenuDegree: 180,
            iconSize: 40,
            onInteractiveActionPerformed: (_, boxInfo) {
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
                width: boxInfo.width,
                height: boxInfo.height,
                rotateAngle: boxInfo.rotateAngle,
                x: boxInfo.x,
                y: boxInfo.y,
              );

              int idx = tables.indexOf(table);

              if (idx == -1) return;

              onUpdate(copiedTable, idx);

              // END comment here if want to see the problem
            },
            onTap: (boxInfo) {
              /// Only tapped table will show icons.
              ///
              /// Might refer to [onInteractiveActionPerformed]
              ///
              // setState(() {
              int idx = tables.indexOf(table);
              TableModel copiedTable = table.copyWith(
                showIcons: !table.showIcons,
              );

              onToggle(copiedTable, idx);
              // tables[idx] = table
              // tables = tables
              //     .map((e) => e.id == table.id
              //         ? e.copyWith(showIcons: true)
              //         : e.copyWith(showIcons: false))
              //     .toList();
              // });
            },
            onActionSelected: (actionType, boxInfo) {
              if (actionType == ControlActionType.copy) {
                TableModel copiedTable = table.copyWith(
                  id: const Uuid().v4(),
                  width: boxInfo.width,
                  height: boxInfo.height,
                  rotateAngle: boxInfo.rotateAngle,
                  showIcons: false,
                  x: boxInfo.x + 50,
                  y: boxInfo.y + 50,
                );

                onAdd(copiedTable);
              } else if (actionType == ControlActionType.delete) {
                int idx = tables.indexOf(table);

                onDel(idx);
              }
            },
            includedActions: const [
              ControlActionType.copy,
              ControlActionType.delete,
              ControlActionType.move,
              ControlActionType.rotate,
              ControlActionType.scale,
            ],
            child: tables[index].image,
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
