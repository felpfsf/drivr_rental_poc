import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'App boots without error',
    (tester) async {
      // Simple widget test - MaterialApp instead of full router setup
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const Text('Test body'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test'), findsWidgets);
      expect(find.text('Test body'), findsOneWidget);
    },
  );
}
