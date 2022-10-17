import 'package:flutter/material.dart';
import 'package:interactive_box/interactive_box.dart';

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
  double xPosition = 100.0; // default should be 0
  double yPosition = 100.0; // default should be 0
  double width = 150;
  double height = 150;
  double maxWidth = 200;
  double maxHeight = 200;
  double rotate = 0;

  // Just a sample, you may use your own List.
  List<String> items = ["a", "b"];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ...List.generate(
          items.length,
          (index) => InteractiveBox(
            initialWidth: width,
            initialHeight: height,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            initialX: xPosition,
            initialY: yPosition,
            initialRotateAngle: rotate,
            includedActions: const [
              ControlActionType.copy,
              ControlActionType.rotate,
              ControlActionType.scale,
              ControlActionType.delete,
              // ControlActionType.delete,
              ControlActionType.move,
            ],
            // circularMenuSpreadMultiplier: 1,
            circularMenuDegree: 230,
            circularMenuIconColor: Colors.green,
            initialShowActionIcons: false,
            iconSize: 40,
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

            onActionSelected:
                (ControlActionType action, InteractiveBoxInfo info) {
              debugPrint("Select $action, info: ${info.toMap()}");

              if (action == ControlActionType.copy) {
                setState(() {
                  items.add("c");
                });
              }

              if (action == ControlActionType.delete) {
                if (items.isEmpty) return;
                setState(() {
                  final int deleteIdx =
                      items.indexWhere((element) => element == items[index]);
                  items.removeAt(deleteIdx);
                });
              }
            },

            /// since this is more an example of how we can use [ControllableItem] widget,
            /// so we use magic string here.
            child: Image.asset(
              "assets/table.png",
              fit: BoxFit.fill,
            ),
          ),
        )
      ],
    );
  }
}
