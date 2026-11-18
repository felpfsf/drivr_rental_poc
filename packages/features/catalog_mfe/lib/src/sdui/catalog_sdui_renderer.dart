import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'catalog_home_layout.dart';

typedef CatalogBlockBuilder = Widget Function(
  BuildContext context,
  CatalogUiBlock block,
  List<Widget> children,
  VoidCallback? onAction,
);

class CatalogSduiRenderer extends StatelessWidget {
  const CatalogSduiRenderer({
    super.key,
    required this.layout,
    required this.onCarSelected,
  });

  final CatalogHomeLayout layout;
  final ValueChanged<String> onCarSelected;

  static final Map<String, CatalogBlockBuilder> _registry = {
    'column': _buildColumn,
    'row': _buildRow,
    'text': _buildText,
    'spacer': _buildSpacer,
    'button': _buildButton,

    // Compatibilidade com o nível 1
    'section_title': _buildSectionTitle,
    'promo_banner': _buildPromoBanner,
  };

  @override
  Widget build(BuildContext context) {
    if (layout.schemaVersion != 1 && layout.schemaVersion != 2) {
      return const _FallbackSection();
    }

    final widgets = <Widget>[];

    for (final block in layout.blocks) {
      final widget = _buildBlock(context, block);
      if (widget != null) widgets.add(widget);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _verticalSpacing(
        widgets,
        AppSpacing.md,
      ),
    );
  }

  Widget? _buildBlock(
    BuildContext context,
    CatalogUiBlock block,
  ) {
    final builder = _registry[block.type];

    // Componentes não registrados são ignorados.
    if (builder == null) return null;

    final children = <Widget>[];

    for (final child in block.children) {
      final widget = _buildBlock(context, child);
      if (widget != null) children.add(widget);
    }

    return builder(
      context,
      block,
      children,
      _resolveAction(block.action),
    );
  }

  VoidCallback? _resolveAction(CatalogUiAction? action) {
    if (action?.type != 'open_car') return null;

    final carId = action?.carId;

    if (carId == null || carId.trim().isEmpty) {
      return null;
    }

    return () => onCarSelected(carId);
  }

  // COMPONENTES DE LAYOUT

  static Widget _buildColumn(
    BuildContext context,
    CatalogUiBlock block,
    List<Widget> children,
    VoidCallback? onAction,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _verticalSpacing(
        children,
        _spacing(block.props['spacing']),
      ),
    );
  }

  static Widget _buildRow(
    BuildContext context,
    CatalogUiBlock block,
    List<Widget> children,
    VoidCallback? onAction,
  ) {
    final gap = _spacing(block.props['spacing']);
    final rowChildren = <Widget>[];

    for (final child in children) {
      if (rowChildren.isNotEmpty) {
        rowChildren.add(SizedBox(width: gap));
      }

      rowChildren.add(Expanded(child: child));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rowChildren,
    );
  }

  // COMPONENTES VISUAIS

  static Widget _buildText(
    BuildContext context,
    CatalogUiBlock block,
    List<Widget> children,
    VoidCallback? onAction,
  ) {
    final value = block.props['value'];

    if (value is! String || value.isEmpty) {
      return const SizedBox.shrink();
    }

    final typography = Theme.of(context).textTheme;

    final style = switch (block.props['style']) {
      'heading' => typography.titleLarge,
      'caption' => typography.bodySmall,
      _ => typography.bodyMedium,
    };

    return Text(
      value,
      style: style,
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }

  static Widget _buildSpacer(
    BuildContext context,
    CatalogUiBlock block,
    List<Widget> children,
    VoidCallback? onAction,
  ) {
    return SizedBox(
      height: _spacing(block.props['size']),
    );
  }

  static Widget _buildButton(
    BuildContext context,
    CatalogUiBlock block,
    List<Widget> children,
    VoidCallback? onAction,
  ) {
    final label = block.props['label'];

    if (label is! String || label.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppButton(
      label: label,
      onPressed: onAction,
    );
  }

  // COMPONENTES LEGADOS DO NÍVEL 1

  static Widget _buildSectionTitle(
    BuildContext context,
    CatalogUiBlock block,
    List<Widget> children,
    VoidCallback? onAction,
  ) {
    final title = block.props['title'];
    final subtitle = block.props['subtitle'];

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
    CatalogUiBlock block,
    List<Widget> children,
    VoidCallback? onAction,
  ) {
    final title = block.props['title'];
    final description = block.props['description'];
    final label = block.props['buttonLabel'];

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
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

  // HELPERS DE LAYOUT

  static double _spacing(dynamic value) {
    return switch (value) {
      'xs' => AppSpacing.xs,
      'sm' => AppSpacing.sm,
      'lg' => AppSpacing.lg,
      'xl' => AppSpacing.xl,
      _ => AppSpacing.md,
    };
  }

  static List<Widget> _verticalSpacing(
    List<Widget> children,
    double spacing,
  ) {
    final result = <Widget>[];

    for (final child in children) {
      if (result.isNotEmpty) {
        result.add(SizedBox(height: spacing));
      }

      result.add(child);
    }

    return result;
  }
}

class _FallbackSection extends StatelessWidget {
  const _FallbackSection();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Explore nossos veículos disponíveis',
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}
