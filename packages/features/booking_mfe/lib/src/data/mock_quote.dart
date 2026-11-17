import 'package:booking_mfe/src/domain/booking_quote.dart';

const _dailyRates = <String, int>{
  'car-001': 120,
  'car-002': 340,
  'car-003': 620,
  'car-004': 580,
};

BookingQuote? mockQuoteFor({
  required String carId,
  required RentalPeriod period,
}) {
  final dailyRate = _dailyRates[carId];

  if (dailyRate == null) return null;

  return BookingQuote(
    period: period,
    dailyRate: dailyRate,
  );
}
