import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

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
    final typography = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: typography.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Explore os veículos disponíveis.',
              style: typography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Selecionar veículo de teste',
              onPressed: () => onCarSelected('car-001'),
            ),
          ],
        ),
      ),
    );
  }
}
