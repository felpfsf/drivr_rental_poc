import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shell_app/main.dart';

void main() {
  testWidgets(
    'Catalog seleciona veículo e abre Booking',
    (tester) async {
      await tester.pumpWidget(const RentalApp());
      await tester.pumpAndSettle();

      expect(find.text('RS 5 Coupé'), findsOneWidget);

      await tester.tap(
        find.byKey(const Key('car_card_car-001')),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Veículo: car-001'),
        findsOneWidget,
      );

      await tester.tap(find.text('Voltar'));
      await tester.pumpAndSettle();

      expect(find.text('RS 5 Coupé'), findsOneWidget);
    },
  );
}
