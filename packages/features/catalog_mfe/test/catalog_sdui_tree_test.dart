import 'package:catalog_mfe/src/sdui/catalog_home_layout.dart';
import 'package:catalog_mfe/src/sdui/catalog_sdui_renderer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('renderiza árvore e executa ação', (tester) async {
    final layout = CatalogHomeLayout.fromJson({
      'schemaVersion': 2,
      'blocks': [
        {
          'type': 'column',
          'children': [
            {
              'type': 'text',
              'props': {
                'value': 'Encontre seu carro',
                'style': 'heading',
              },
            },
            {
              'type': 'row',
              'children': [
                {
                  'type': 'text',
                  'props': {'value': 'Premium'},
                },
                {
                  'type': 'text',
                  'props': {'value': 'Esportivo'},
                },
              ],
            },
            {
              'type': 'button',
              'props': {'label': 'Ver Audi'},
              'action': {
                'type': 'open_car',
                'carId': 'car-001',
              },
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
          body: SingleChildScrollView(
            child: CatalogSduiRenderer(
              layout: layout,
              onCarSelected: (id) => selectedCarId = id,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Encontre seu carro'), findsOneWidget);
    expect(find.text('Premium'), findsOneWidget);
    expect(find.text('Esportivo'), findsOneWidget);

    await tester.tap(find.text('Ver Audi'));

    expect(selectedCarId, 'car-001');
  });

  test('rejeita árvore acima da profundidade máxima', () {
    Map<String, dynamic> node = {
      'type': 'text',
      'props': {'value': 'Muito profundo'},
    };

    for (var i = 0; i < 6; i++) {
      node = {
        'type': 'column',
        'children': [node],
      };
    }

    expect(
      () => CatalogHomeLayout.fromJson({
        'schemaVersion': 2,
        'blocks': [node],
      }),
      throwsFormatException,
    );
  });

  test('rejeita payload com mais de 50 nós', () {
    expect(
      () => CatalogHomeLayout.fromJson({
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
}
