import 'package:catalog_mfe/src/models/drivr_rental_car.dart';
import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

class CarImage extends StatelessWidget {
  const CarImage({
    super.key,
    required this.car,
    this.color = AppColors.primary,
    this.iconSize = 72,
  });

  final DrivrRentalCar car;
  final Color color;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final placeholder = Center(
      child: Icon(
        Icons.directions_car_filled_rounded,
        size: iconSize,
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
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}
