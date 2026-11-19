import 'package:booking_mfe/src/data/booking_repository.dart';
import 'package:booking_mfe/src/domain/booking_quote.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

class RecordingApiClient extends ApiClient {
  RecordingApiClient() : super(baseUrl: 'http://localhost:3000');

  String? lastPath;
  Map<String, dynamic>? lastBody;

  @override
  Future<dynamic> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    lastPath = path;
    lastBody = body;

    return {
      'id': 'booking-test-001',
      'carId': body['carId'],
      'status': 'confirmed',
    };
  }
}

void main() {
  test('cria reserva e interpreta a confirmação', () async {
    final api = RecordingApiClient();
    addTearDown(api.close);

    final repository = HttpBookingRepository(api);

    final confirmation = await repository.createBooking(
      carId: 'car-001',
      period: RentalPeriod(
        start: DateTime(2026, 11, 20),
        end: DateTime(2026, 11, 22),
      ),
    );

    expect(api.lastPath, '/bookings');

    expect(api.lastBody, {
      'carId': 'car-001',
      'startDate': '2026-11-20',
      'endDate': '2026-11-22',
    });

    expect(confirmation.id, 'booking-test-001');
    expect(confirmation.status, 'confirmed');
  });
}
