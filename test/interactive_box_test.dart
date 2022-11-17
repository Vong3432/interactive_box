import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_box/interactive_box.dart';

void main() {
  group("InteractiveBox", () {
    group("Custom toggle", () {
      testWidgets(
        'Should trigger onTap() if [toggleBy] is [ToggleActionType.onTap]',
        (tester) async {
          bool success = false;

          const boxPosition = Offset(100, 100);
          const boxSize = Size(100, 100);
          final tapPosition = Offset(boxPosition.dx + boxSize.width / 2,
              boxPosition.dy + boxSize.height / 2);
          final box = InteractiveBox(
            initialPosition: boxPosition,
            initialSize: boxSize,
            toggleBy: ToggleActionType.onTap,
            onMenuToggled: (_) {
              success = true;
            },
            shape: Shape.rectangle,
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Stack(
                children: [
                  box,
                ],
              ),
            ),
          );
          await tester.pumpAndSettle();

          // make sure box exists
          expect(find.byWidget(box), findsOneWidget);

          await tester.tapAt(tapPosition);
          await tester.pumpAndSettle();

          expect(success, true);
        },
      );

      testWidgets(
        'Should trigger onLongPress() if [toggleBy] is [ToggleActionType.onLongPress]',
        (tester) async {
          bool success = false;

          const boxPosition = Offset(100, 100);
          const boxSize = Size(100, 100);
          final tapPosition = Offset(boxPosition.dx + boxSize.width / 2,
              boxPosition.dy + boxSize.height / 2);
          final box = InteractiveBox(
            initialPosition: boxPosition,
            initialSize: boxSize,
            toggleBy: ToggleActionType.onLongPress,
            onMenuToggled: (_) {
              success = true;
            },
            shape: Shape.rectangle,
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Stack(
                children: [
                  box,
                ],
              ),
            ),
          );
          await tester.pumpAndSettle();

          // make sure box exists
          expect(find.byWidget(box), findsOneWidget);

          await tester.longPressAt(tapPosition);
          await tester.pumpAndSettle();

          expect(success, true);
        },
      );

      testWidgets(
        'Should trigger onDoubleTap() if [toggleBy] is [ToggleActionType.onDoubleTap]',
        (tester) async {
          bool success = false;

          const boxPosition = Offset(100, 100);
          const boxSize = Size(100, 100);
          final tapPosition = Offset(boxPosition.dx + boxSize.width / 2,
              boxPosition.dy + boxSize.height / 2);
          final box = InteractiveBox(
            initialPosition: boxPosition,
            initialSize: boxSize,
            toggleBy: ToggleActionType.onDoubleTap,
            onMenuToggled: (_) {
              success = true;
            },
            shape: Shape.rectangle,
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Stack(
                children: [
                  box,
                ],
              ),
            ),
          );
          await tester.pumpAndSettle();

          // make sure box exists
          expect(find.byWidget(box), findsOneWidget);

          await tester.tapAt(tapPosition);
          await tester.pump(kDoubleTapMinTime);
          await tester.tapAt(tapPosition);
          await tester.pumpAndSettle();

          expect(success, true);
        },
      );

      testWidgets(
        'Should trigger onSecondaryTap() if [toggleBy] is [ToggleActionType.onSecondaryTap]',
        (tester) async {
          bool success = false;

          const boxPosition = Offset(100, 100);
          const boxSize = Size(100, 100);
          final tapPosition = Offset(boxPosition.dx + boxSize.width / 2,
              boxPosition.dy + boxSize.height / 2);
          final box = InteractiveBox(
            initialPosition: boxPosition,
            initialSize: boxSize,
            toggleBy: ToggleActionType.onSecondaryTap,
            onMenuToggled: (_) {
              success = true;
            },
            shape: Shape.rectangle,
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Stack(
                children: [
                  box,
                ],
              ),
            ),
          );
          await tester.pumpAndSettle();

          // make sure box exists
          expect(find.byWidget(box), findsOneWidget);

          await tester.tapAt(tapPosition, buttons: kSecondaryButton);
          await tester.pumpAndSettle();

          expect(success, true);
        },
      );
    });
  });
}
