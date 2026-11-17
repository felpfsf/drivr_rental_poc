class DrivrRentalCar {
  final String id;
  final String brand;
  final String model;
  final int dailyPrice;

  final int topSpeedKmh;
  final double accelerationSeconds;
  final int horsePower;

  final String fuel;
  final String transmission;
  final int seats;

  final String description;
  final String? imageAsset;

  const DrivrRentalCar({
    required this.id,
    required this.brand,
    required this.model,
    required this.dailyPrice,
    required this.topSpeedKmh,
    required this.accelerationSeconds,
    required this.horsePower,
    required this.fuel,
    required this.transmission,
    required this.seats,
    required this.description,
    this.imageAsset,
  });
}
