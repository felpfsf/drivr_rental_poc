import 'package:core/core.dart';

import '../domain/booking_quote.dart';

abstract interface class BookingRepository {
  Future<BookingQuote> getQuote({
    required String carId,
    required RentalPeriod period,
  });
}

class HttpBookingRepository implements BookingRepository {
  const HttpBookingRepository(this._api);

  final ApiClient _api;

  @override
  Future<BookingQuote> getQuote({
    required String carId,
    required RentalPeriod period,
  }) async {
    String formatDate(DateTime date) {
      return '${date.year}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    }

    final response = await _api.post(
      '/bookings/quote',
      {
        'carId': carId,
        'startDate': formatDate(period.start),
        'endDate': formatDate(period.end),
        'days': period.days,
      },
    );

    final json = Map<String, dynamic>.from(response as Map);

    return BookingQuote(
      period: period,
      dailyRate: (json['dailyRate'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );
  }
}
