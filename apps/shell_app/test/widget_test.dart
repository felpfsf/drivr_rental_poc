import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shell_app/main.dart';

void main() {
  testWidgets(
    'Catalog abre detalhes e inicia Booking',
    (tester) async {
      await tester.pumpWidget(const RentalApp());
      await tester.pumpAndSettle();

      // Seleciona um veículo no catálogo.
      await tester.tap(
        find.byKey(const Key('car_card_car-001')),
      );
      await tester.pumpAndSettle();

      // Valida a tela de detalhes.
      expect(find.text('RS 5 Coupé'), findsOneWidget);
      expect(
        find.text('Escolher período do aluguel'),
        findsOneWidget,
      );

      // Solicita agendamento.
      await tester.tap(
        find.text('Escolher período do aluguel'),
      );
      await tester.pumpAndSettle();

      // Valida a comunicação com Booking.
      expect(
        find.text('Veículo: car-001'),
        findsOneWidget,
      );

      // Retorna para os detalhes.
      await tester.tap(find.text('Voltar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Escolher período do aluguel'),
        findsOneWidget,
      );
    },
  );
}
