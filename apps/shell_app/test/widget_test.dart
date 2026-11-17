import 'package:flutter_test/flutter_test.dart';
import 'package:shell_app/main.dart';

void main() {
  testWidgets('switches between app sections', (tester) async {
    await tester.pumpWidget(const RentalApp());
    await tester.pumpAndSettle();

    expect(find.text('Selecionar veículo de teste'), findsOneWidget);

    await tester.tap(find.text('Conta'));
    await tester.pumpAndSettle();

    expect(find.text('account_mfe'), findsOneWidget);

    await tester.tap(find.text('Carros'));
    await tester.pumpAndSettle();

    expect(find.text('Buscar carros'), findsOneWidget);
  });

  testWidgets('opens booking from catalog and returns to catalog', (
    tester,
  ) async {
    await tester.pumpWidget(const RentalApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Selecionar veículo de teste'));
    await tester.pumpAndSettle();

    expect(find.text('Veículo: car-001'), findsOneWidget);

    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();

    expect(find.text('Selecionar veículo de teste'), findsOneWidget);
  });
}
