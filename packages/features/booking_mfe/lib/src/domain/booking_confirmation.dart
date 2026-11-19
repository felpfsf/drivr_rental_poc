class BookingConfirmation {
  const BookingConfirmation({
    required this.id,
    required this.carId,
    required this.status,
  });

  final String id;
  final String carId;
  final String status;

  factory BookingConfirmation.fromJson(
    Map<String, dynamic> json,
  ) {
    return BookingConfirmation(
      id: json['id'] as String,
      carId: json['carId'] as String,
      status: json['status'] as String,
    );
  }
}
