import 'package:booking_mfe/booking_mfe.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows selected car and invokes close callback', (tester) async {
    var didClose = false;

    await tester.pumpWidget(
      MaterialApp(
        home: BookingPage(
          carId: 'car-001',
          onClose: () => didClose = true,
        ),
      ),
    );

    expect(find.text('Veículo: car-001'), findsOneWidget);

    await tester.tap(find.text('Voltar'));

    expect(didClose, isTrue);
  });
}
