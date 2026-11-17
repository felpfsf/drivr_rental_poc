import 'package:catalog_mfe/src/data/mock_cars.dart';
import 'package:catalog_mfe/src/models/drivr_rental_car.dart';
import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import 'widgets/car_image.dart';

class CarDetailsPage extends StatelessWidget {
  const CarDetailsPage({
    super.key,
    required this.carId,
    required this.onBack,
    required this.onBookingRequested,
  });

  final String carId;
  final VoidCallback onBack;
  final ValueChanged<String> onBookingRequested;

  @override
  Widget build(BuildContext context) {
    final car = findCarById(carId);

    if (car == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: onBack),
        ),
        body: const Center(
          child: Text('Veículo não encontrado'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: BackButton(onPressed: onBack),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Text(
              '● ○ ○ ○',
              style: TextStyle(color: AppColors.muted),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          SizedBox(
            height: 220,
            child: CarImage(
              car: car,
              iconSize: 150,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _CarIdentity(car: car),
          const SizedBox(height: AppSpacing.md),
          _Specifications(car: car),
          const SizedBox(height: AppSpacing.lg),
          Text(
            car.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.muted,
              height: 1.6,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AppButton(
            label: 'Escolher período do aluguel',
            onPressed: () => onBookingRequested(car.id),
          ),
        ),
      ),
    );
  }
}

class _CarIdentity extends StatelessWidget {
  const _CarIdentity({required this.car});

  final DrivrRentalCar car;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                car.brand.toUpperCase(),
                style: typography.bodySmall,
              ),
              Text(
                car.model,
                style: typography.titleLarge,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'AO DIA',
              style: typography.bodySmall,
            ),
            Text(
              'R\$ ${car.dailyPrice}',
              style: typography.titleLarge?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Specifications extends StatelessWidget {
  const _Specifications({required this.car});

  final DrivrRentalCar car;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      childAspectRatio: 1.1,
      children: [
        _SpecTile(
          icon: Icons.speed,
          value: '${car.topSpeedKmh} km/h',
        ),
        _SpecTile(
          icon: Icons.trending_up,
          value: '${car.accelerationSeconds.toStringAsFixed(1)}s',
        ),
        _SpecTile(
          icon: Icons.settings,
          value: '${car.horsePower} HP',
        ),
        _SpecTile(
          icon: Icons.local_gas_station_outlined,
          value: car.fuel,
        ),
        _SpecTile(
          icon: Icons.tune,
          value: car.transmission,
        ),
        _SpecTile(
          icon: Icons.people_outline,
          value: '${car.seats} pessoas',
        ),
      ],
    );
  }
}

class _SpecTile extends StatelessWidget {
  const _SpecTile({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.canvas,
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.ink,
            size: 26,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
