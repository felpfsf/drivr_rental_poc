import 'package:catalog_mfe/catalog_mfe.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows catalog title and reports selected car', (tester) async {
    String? selectedCarId;

    await tester.pumpWidget(
      MaterialApp(
        home: CatalogPage(
          title: 'Buscar carros',
          onCarSelected: (carId) => selectedCarId = carId,
        ),
      ),
    );

    expect(find.text('Buscar carros'), findsOneWidget);

    await tester.tap(find.text('Selecionar veículo de teste'));

    expect(selectedCarId, 'car-001');
  });
}
