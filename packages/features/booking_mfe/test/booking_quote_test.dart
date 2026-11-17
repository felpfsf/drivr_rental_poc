import 'package:booking_mfe/src/data/mock_quote.dart';
import 'package:booking_mfe/src/domain/booking_quote.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RentalPeriod', () {
    test('conta dias incluindo início e término', () {
      final period = RentalPeriod(
        start: DateTime(2026, 11, 17),
        end: DateTime(2026, 11, 19),
      );

      expect(period.days, 3);
    });

    test('mesma data equivale a uma diária', () {
      final period = RentalPeriod(
        start: DateTime(2026, 11, 17),
        end: DateTime(2026, 11, 17),
      );

      expect(period.days, 1);
    });

    test('rejeita período invertido', () {
      expect(
        () => RentalPeriod(
          start: DateTime(2026, 11, 20),
          end: DateTime(2026, 11, 17),
        ),
        throwsArgumentError,
      );
    });
  });

  test('calcula corretamente orçamento mockado', () {
    final quote = mockQuoteFor(
      carId: 'car-001',
      period: RentalPeriod(
        start: DateTime(2026, 11, 17),
        end: DateTime(2026, 11, 19),
      ),
    );

    expect(quote, isNotNull);
    expect(quote!.dailyRate, 120);
    expect(quote.total, 360);
  });
}
