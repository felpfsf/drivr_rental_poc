import 'package:material_ui/material_ui.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key, required this.title, required this.onCarSelected});

  final String title;
  final ValueChanged<String> onCarSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 12),
          const Text('Catalog MFE'),
          SizedBox(height: 24),
          FilledButton(
            onPressed: () => onCarSelected('car-001'),
            child: const Text('Selecionar veículo de teste'),
          ),
        ],
      ),
    );
  }
}
