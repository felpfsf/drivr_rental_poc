import 'package:catalog_mfe/src/models/drivr_rental_car.dart';

const mockCars = <DrivrRentalCar>[
  DrivrRentalCar(
    id: 'car-001',
    brand: 'Audi',
    model: 'RS 5 Coupé',
    dailyPrice: 120,
    topSpeedKmh: 250,
    accelerationSeconds: 3.9,
    horsePower: 450,
    fuel: 'Gasolina',
    transmission: 'Automático',
    seats: 4,
    description:
        'Um coupé esportivo que combina desempenho, '
        'conforto e uma experiência de direção marcante.',
    imageAsset: 'assets/cars/audi_rs5.png',
  ),
  DrivrRentalCar(
    id: 'car-002',
    brand: 'Porsche',
    model: 'Panamera',
    dailyPrice: 340,
    topSpeedKmh: 270,
    accelerationSeconds: 5.5,
    horsePower: 330,
    fuel: 'Gasolina',
    transmission: 'Automático',
    seats: 4,
    description:
        'Um sedã esportivo que une sofisticação, '
        'tecnologia e desempenho.',
    imageAsset: 'assets/cars/porsche_panamera.png',
  ),
  DrivrRentalCar(
    id: 'car-003',
    brand: 'Chevrolet',
    model: 'Corvette Z06',
    dailyPrice: 620,
    topSpeedKmh: 315,
    accelerationSeconds: 3.0,
    horsePower: 670,
    fuel: 'Gasolina',
    transmission: 'Automático',
    seats: 2,
    description:
        'Um superesportivo de personalidade forte, '
        'feito para quem busca emoções ao volante.',
    imageAsset: 'assets/cars/corvette_z06.png',
  ),
  DrivrRentalCar(
    id: 'car-004',
    brand: 'Lamborghini',
    model: 'Huracán',
    dailyPrice: 580,
    topSpeedKmh: 325,
    accelerationSeconds: 2.9,
    horsePower: 640,
    fuel: 'Gasolina',
    transmission: 'Automático',
    seats: 2,
    description:
        'Um superesportivo de design icônico, '
        'com desempenho extremo e uma experiência '
        'de direção envolvente.',
    imageAsset: 'assets/cars/lamborghini_huracan.png',
  ),
];

DrivrRentalCar? findCarById(String id) {
  for (final car in mockCars) {
    if (car.id == id) return car;
  }

  return null;
}
