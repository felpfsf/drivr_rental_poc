import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sdui_engine/sdui_engine.dart';

void main() {
  test('interpreta uma árvore de componentes', () {
    final document = SduiParser.parse({
      'schemaVersion': 2,
      'blocks': [
        {
          'type': 'column',
          'children': [
            {
              'type': 'text',
              'props': {'value': 'Olá, SDUI'},
            },
          ],
        },
      ],
    });

    expect(document.schemaVersion, 2);
    expect(document.blocks.first.type, 'column');
    expect(document.blocks.first.children.first.type, 'text');
  });

  test('rejeita mais de 50 nós', () {
    expect(
      () => SduiParser.parse({
        'schemaVersion': 2,
        'blocks': List.generate(
          51,
          (_) => {
            'type': 'text',
            'props': {'value': 'Texto'},
          },
        ),
      }),
      throwsFormatException,
    );
  });

  testWidgets('aceita componentes e ações externas', (tester) async {
    final registry = createStandardSduiRegistry().withComponents({
      'feature_badge': (context, node, children, onAction) {
        return Text(node.props['label'] as String);
      },
    });

    final document = SduiParser.parse({
      'schemaVersion': 2,
      'blocks': [
        {
          'type': 'column',
          'children': [
            {
              'type': 'feature_badge',
              'props': {'label': 'Componente do MFE'},
            },
            {
              'type': 'button',
              'props': {'label': 'Ver veículo'},
              'action': {'type': 'open_car', 'carId': 'car-001'},
            },
          ],
        },
      ],
    });

    String? selectedCarId;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(splashFactory: NoSplash.splashFactory),
        home: Scaffold(
          body: SduiRenderer(
            document: document,
            registry: registry,
            actionResolver: (action) {
              final carId = action.params['carId'];

              if (action.type == 'open_car' && carId is String) {
                return () => selectedCarId = carId;
              }

              return null;
            },
          ),
        ),
      ),
    );

    expect(find.text('Componente do MFE'), findsOneWidget);

    await tester.tap(find.text('Ver veículo'));

    expect(selectedCarId, 'car-001');
  });
}
