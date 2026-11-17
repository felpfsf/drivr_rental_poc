class DrivrRentalCar {
  final String id;
  final String brand;
  final String model;
  final int dailyPrice;

  final String? imageAsset;

  const DrivrRentalCar({
    required this.id,
    required this.brand,
    required this.model,
    required this.dailyPrice,
    this.imageAsset,
  });
}
