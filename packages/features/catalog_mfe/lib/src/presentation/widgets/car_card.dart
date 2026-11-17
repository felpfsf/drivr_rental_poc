import 'package:catalog_mfe/src/models/drivr_rental_car.dart';
import 'package:catalog_mfe/src/presentation/widgets/car_image.dart';
import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

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
                  child: CarImage(
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
