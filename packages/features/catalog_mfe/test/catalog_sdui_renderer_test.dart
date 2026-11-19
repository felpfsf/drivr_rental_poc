import 'package:catalog_mfe/src/sdui/catalog_home_layout.dart';
import 'package:catalog_mfe/src/sdui/catalog_sdui_renderer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('renderiza componentes e executa ação', (tester) async {
    final layout = CatalogHomeLayout.fromJson({
      'schemaVersion': 1,
      'blocks': [
        {
          'type': 'section_title',
          'props': {
            'title': 'Destaques',
          },
        },
        {
          'type': 'promo_banner',
          'props': {
            'title': 'Conheça nosso Audi',
            'buttonLabel': 'Ver veículo',
          },
          'action': {
            'type': 'open_car',
            'carId': 'car-001',
          },
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

    expect(find.text('Destaques'), findsOneWidget);
    expect(find.text('Conheça nosso Audi'), findsOneWidget);

    await tester.tap(find.text('Ver veículo'));

    expect(selectedCarId, 'car-001');
  });

  testWidgets('usa fallback para schema incompatível', (
    tester,
  ) async {
    const layout = CatalogHomeLayout(
      schemaVersion: 99,
      blocks: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CatalogSduiRenderer(
            layout: layout,
            onCarSelected: (_) {},
          ),
        ),
      ),
    );

    expect(
      find.text('Explore nossos veículos disponíveis'),
      findsOneWidget,
    );
  });

  testWidgets('ignora componentes desconhecidos', (
    tester,
  ) async {
    final layout = CatalogHomeLayout.fromJson({
      'schemaVersion': 1,
      'blocks': [
        {
          'type': 'unknown_component',
          'props': {'title': 'Desconhecido'},
        },
        {
          'type': 'section_title',
          'props': {'title': 'Carros disponíveis'},
        },
      ],
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CatalogSduiRenderer(
            layout: layout,
            onCarSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Desconhecido'), findsNothing);
    expect(find.text('Carros disponíveis'), findsOneWidget);
  });
}
