import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sdui_engine/sdui_engine.dart';

void main() {
  testWidgets('ignora propriedades inválidas sem afetar outros nós', (
    tester,
  ) async {
    final document = SduiParser.parse({
      'schemaVersion': 2,
      'blocks': [
        {
          'type': 'text',
          'props': {'value': 123},
        },
        {
          'type': 'text',
          'props': {'value': 'Componente válido'},
        },
      ],
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SduiRenderer(
            document: document,
            registry: createStandardSduiRegistry(),
            actionResolver: (_) => null,
          ),
        ),
      ),
    );

    expect(find.text('Componente válido'), findsOneWidget);

    expect(find.byType(Text), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ação desconhecida mantém botão desabilitado', (tester) async {
    final document = SduiParser.parse({
      'schemaVersion': 2,
      'blocks': [
        {
          'type': 'button',
          'props': {'label': 'Executar ação'},
          'action': {'type': 'unknown_action'},
        },
      ],
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SduiRenderer(
            document: document,
            registry: createStandardSduiRegistry(),
            actionResolver: (_) => null,
          ),
        ),
      ),
    );

    final button = tester.widget<FilledButton>(find.byType(FilledButton));

    expect(button.onPressed, isNull);
  });

  test('rejeita espaçamento inválido', () {
    final registry = createStandardSduiRegistry();

    const node = SduiNode(type: 'spacer', props: {'size': '999px'});

    expect(registry.validate(node), isNotNull);
  });
}
