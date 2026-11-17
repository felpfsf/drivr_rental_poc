import 'package:catalog_mfe/catalog_mfe.dart';
import 'package:catalog_mfe/src/models/drivr_rental_car.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'widgets/car_card.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({
    super.key,
    required this.title,
    required this.onCarSelected,
    required this.repository,
  });

  final String title;
  final ValueChanged<String> onCarSelected;
  final CatalogRepository repository;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late Future<List<DrivrRentalCar>> _carsFuture;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  void _loadCars() {
    _carsFuture = widget.repository.getCars();
  }

  void _retry() {
    setState(_loadCars);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DrivrRentalCar>>(
      future: _carsFuture,
      builder: (context, snapshot) {
        final cars = snapshot.data ?? <DrivrRentalCar>[];

        Widget content;

        if (snapshot.connectionState != ConnectionState.done) {
          content = const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          content = Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Não foi possível carregar os carros'),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _retry,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        } else if (cars.isEmpty) {
          content = const Center(
            child: Text('Nenhum veículo disponível'),
          );
        } else {
          content = ListView.separated(
            key: const Key('catalog_list'),
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: cars.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final car = cars[index];

              return CarCard(
                car: car,
                thumbnailColor: AppColors.primary,
                onTap: () => widget.onCarSelected(car.id),
              );
            },
          );
        }

        return Column(
          children: [
            _CatalogHeader(totalCars: cars.length),
            Expanded(child: content),
          ],
        );
      },
    );
  }
}

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader({required this.totalCars});

  final int totalCars;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: AppColors.ink,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 72,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    color: AppColors.primary,
                    child: const Text(
                      'R',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text(
                    'RENTAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Total $totalCars carros',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
