import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/drivr_rental_car.dart';

class CarCard extends StatelessWidget {
  const CarCard({
    super.key,
    required this.car,
    required this.onTap,
    required this.thumbnailColor,
  });

  final DrivrRentalCar car;
  final VoidCallback onTap;
  final Color thumbnailColor;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(2),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('car_card_${car.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SizedBox(
            height: 100,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car.brand.toUpperCase(),
                        style: typography.bodySmall?.copyWith(
                          fontSize: 10,
                          color: AppColors.muted,
                        ),
                      ),
                      Text(
                        car.model,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.titleLarge?.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'AO DIA',
                        style: typography.bodySmall?.copyWith(
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'R\$ ${car.dailyPrice}',
                        style: typography.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 5,
                  child: _CarThumbnail(
                    car: car,
                    color: thumbnailColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CarThumbnail extends StatelessWidget {
  const _CarThumbnail({
    required this.car,
    required this.color,
  });

  final DrivrRentalCar car;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.directions_car_filled_rounded,
        size: 72,
        color: color,
      ),
    );

    if (car.imageAsset == null) {
      return placeholder;
    }

    return Image.asset(
      car.imageAsset!,
      package: 'catalog_mfe',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return placeholder;
      },
    );
  }
}
