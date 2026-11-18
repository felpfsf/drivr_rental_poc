import 'package:booking_mfe/src/domain/booking_confirmation.dart';
import 'package:booking_mfe/src/domain/booking_quote.dart';
import 'package:core/core.dart';

abstract interface class BookingRepository {
  Future<BookingQuote> getQuote({
    required String carId,
    required RentalPeriod period,
  });

  Future<BookingConfirmation> createBooking({
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
    final response = await _api.post(
      '/bookings/quote',
      {
        'carId': carId,
        'startDate': _formatDate(period.start),
        'endDate': _formatDate(period.end),
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

  @override
  Future<BookingConfirmation> createBooking({
    required String carId,
    required RentalPeriod period,
  }) async {
    final response = await _api.post(
      '/bookings',
      {
        'carId': carId,
        'startDate': _formatDate(period.start),
        'endDate': _formatDate(period.end),
      },
    );

    final json = Map<String, dynamic>.from(response as Map);

    return BookingConfirmation.fromJson(json);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
