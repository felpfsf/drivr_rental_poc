import 'package:booking_mfe/booking_mfe.dart';
import 'package:booking_mfe/src/domain/booking_quote.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('shows selected car info', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('pt', 'BR')],
        home: BookingPage(
          carId: 'car-001',
          onClose: () {},
          repository: _BookingRepositoryFake(),
          ensureAuthenticated: () async => true,
        ),
      ),
    );

    expect(find.text('Veículo: car-001'), findsOneWidget);
  });
}

class _BookingRepositoryFake implements BookingRepository {
  @override
  Future<BookingQuote> getQuote({
    required String carId,
    required RentalPeriod period,
  }) async {
    return BookingQuote(
      period: period,
      dailyRate: 120,
      total: 120 * period.days,
    );
  }

  @override
  Future<BookingConfirmation> createBooking({
    required String carId,
    required RentalPeriod period,
  }) async {
    return BookingConfirmation(
      id: 'booking-001',
      carId: carId,
      status: 'confirmed',
    );
  }
}
