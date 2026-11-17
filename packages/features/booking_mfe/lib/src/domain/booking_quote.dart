class RentalPeriod {
  final DateTime start;
  final DateTime end;

  RentalPeriod({
    required this.start,
    required this.end,
  }) {
    if (days <= 0) {
      throw ArgumentError("Periodo inválido");
    }
  }

  int get days {
    final from = DateTime.utc(
      start.year,
      start.month,
      start.day,
    );

    final to = DateTime.utc(
      end.year,
      end.month,
      end.day,
    );

    return to.difference(from).inDays + 1;
  }
}

class BookingQuote {
  final RentalPeriod period;
  final int dailyRate;

  BookingQuote({
    required this.period,
    required this.dailyRate,
  });

  int get total => period.days * dailyRate;
}
