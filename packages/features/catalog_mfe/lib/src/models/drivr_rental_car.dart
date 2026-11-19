class DrivrRentalCar {
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

  factory DrivrRentalCar.fromJson(
    Map<String, dynamic> json,
  ) {
    const localImages = <String, String>{
      'car-001': 'assets/cars/audi_rs5.png',
      'car-002': 'assets/cars/porsche_panamera.png',
      'car-003': 'assets/cars/corvette_z06.png',
      'car-004': 'assets/cars/lamborghini_huracan.png',
    };

    final id = json['id'] as String;

    return DrivrRentalCar(
      id: id,
      brand: json['brand'] as String,
      model: json['model'] as String,
      dailyPrice: (json['dailyPrice'] as num).toInt(),
      topSpeedKmh: (json['topSpeedKmh'] as num).toInt(),
      accelerationSeconds: (json['accelerationSeconds'] as num).toDouble(),
      horsePower: (json['horsePower'] as num).toInt(),
      fuel: json['fuel'] as String,
      transmission: json['transmission'] as String,
      seats: (json['seats'] as num).toInt(),
      description: json['description'] as String,
      imageAsset: localImages[id],
    );
  }
}
