import 'package:booking_mfe/booking_mfe.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows selected car info', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BookingPage(
          carId: 'car-001',
          onClose: () {},
        ),
      ),
    );

    expect(find.text('Veículo: car-001'), findsOneWidget);
  });
}
