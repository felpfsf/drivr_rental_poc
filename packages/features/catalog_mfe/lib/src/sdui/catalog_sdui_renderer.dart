import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sdui_engine/sdui_engine.dart';

import 'catalog_home_layout.dart';

class CatalogSduiRenderer extends StatelessWidget {
  const CatalogSduiRenderer({
    super.key,
    required this.layout,
    required this.onCarSelected,
  });

  final CatalogHomeLayout layout;
  final ValueChanged<String> onCarSelected;

  static final SduiRegistry _registry = createStandardSduiRegistry()
      .withComponents({
        'section_title': _buildSectionTitle,
        'promo_banner': _buildPromoBanner,
      })
      .withValidators({
        'section_title': (node) {
          return _validateTitle(node);
        },
        'promo_banner': (node) {
          return _validateTitle(node);
        },
      });

  static String? _validateTitle(SduiNode node) {
    final title = node.props['title'];

    if (title is! String || title.trim().isEmpty) {
      return 'Título obrigatório';
    }

    if (title.length > 100) {
      return 'Título excede 100 caracteres';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SduiRenderer(
      document: layout,
      registry: _registry,
      actionResolver: _resolveAction,
      fallback: Text(
        'Explore nossos veículos disponíveis',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  VoidCallback? _resolveAction(SduiAction action) {
    if (action.type != 'open_car') return null;

    final carId = action.params['carId'];

    if (carId is! String || carId.trim().isEmpty) {
      return null;
    }

    return () => onCarSelected(carId);
  }

  static Widget _buildSectionTitle(
    BuildContext context,
    SduiNode node,
    List<Widget> children,
    VoidCallback? onAction,
  ) {
    final title = node.props['title'];
    final subtitle = node.props['subtitle'];

    if (title is! String || title.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (subtitle is String && subtitle.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  static Widget _buildPromoBanner(
    BuildContext context,
    SduiNode node,
    List<Widget> children,
    VoidCallback? onAction,
  ) {
    final title = node.props['title'];
    final description = node.props['description'];
    final label = node.props['buttonLabel'];

    if (title is! String || title.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.directions_car_outlined,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (description is String && description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: const TextStyle(
                color: AppColors.muted,
              ),
            ),
          ],
          if (onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: label is String && label.isNotEmpty ? label : 'Saiba mais',
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
