import 'package:catalog_mfe/catalog_mfe.dart';
import 'package:catalog_mfe/src/models/drivr_rental_car.dart';
import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import 'widgets/car_image.dart';

class CarDetailsPage extends StatefulWidget {
  const CarDetailsPage({
    super.key,
    required this.carId,
    required this.onBack,
    required this.onBookingRequested,
    required this.repository,
  });

  final String carId;
  final VoidCallback onBack;
  final ValueChanged<String> onBookingRequested;
  final CatalogRepository repository;

  @override
  State<CarDetailsPage> createState() => _CarDetailsPageState();
}

class _CarDetailsPageState extends State<CarDetailsPage> {
  late Future<DrivrRentalCar?> _carFuture;

  @override
  void initState() {
    super.initState();
    _loadCar();
  }

  void _loadCar() {
    _carFuture = widget.repository.getCarById(widget.carId);
  }

  void _retry() {
    setState(_loadCar);
  }

  @override
  void didUpdateWidget(covariant CarDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.carId != widget.carId ||
        oldWidget.repository != widget.repository) {
      _loadCar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DrivrRentalCar?>(
      future: _carFuture,
      builder: (context, snapshot) {
        final car = snapshot.data;
        final hasLoadedCar =
            snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError &&
            car != null;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            leading: BackButton(onPressed: widget.onBack),
            actions: hasLoadedCar
                ? const [
                    Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Text(
                        '● ○ ○ ○',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ),
                  ]
                : const [],
          ),
          body: _buildBody(context, snapshot),
          bottomNavigationBar: hasLoadedCar
              ? SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: AppButton(
                      label: 'Escolher período do aluguel',
                      onPressed: () => widget.onBookingRequested(car.id),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<DrivrRentalCar?> snapshot,
  ) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Não foi possível carregar o veículo'),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _retry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final car = snapshot.data;
    if (car == null) {
      return const Center(
        child: Text('Veículo não encontrado'),
      );
    }

    return ListView(
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
