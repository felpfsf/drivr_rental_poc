import 'package:design_system/design_system.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../data/mock_cars.dart';
import 'widgets/car_card.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({
    super.key,
    required this.title,
    required this.onCarSelected,
  });

  final String title;
  final ValueChanged<String> onCarSelected;

  @override
  Widget build(BuildContext context) {
    const thumbnailColors = [
      Color(0xFF8B929B),
      Color(0xFF38393C),
      Color(0xFFE1B900),
      AppColors.primary,
    ];

    return Semantics(
      label: '$title - catálogo de veículos',
      child: Column(
        children: [
          _CatalogHeader(totalCars: mockCars.length),
          Expanded(
            child: ListView.separated(
              key: const Key('catalog_list'),
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: mockCars.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final car = mockCars[index];

                return CarCard(
                  car: car,
                  thumbnailColor:
                      thumbnailColors[index % thumbnailColors.length],
                  onTap: () => onCarSelected(car.id),
                );
              },
            ),
          ),
        ],
      ),
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
