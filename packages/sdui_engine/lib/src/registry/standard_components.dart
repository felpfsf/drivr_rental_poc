import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../models/sdui_document.dart';
import 'sdui_registry.dart';

SduiRegistry createStandardSduiRegistry() {
  return SduiRegistry({
    'column': _buildColumn,
    'row': _buildRow,
    'text': _buildText,
    'spacer': _buildSpacer,
    'button': _buildButton,
  });
}

Widget _buildColumn(
  BuildContext context,
  SduiNode node,
  List<Widget> children,
  VoidCallback? onAction,
) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: _withSpacing(children, _spacing(node.props['spacing'])),
  );
}

Widget _buildRow(
  BuildContext context,
  SduiNode node,
  List<Widget> children,
  VoidCallback? onAction,
) {
  final gap = _spacing(node.props['spacing']);

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) SizedBox(width: gap),
        Expanded(child: children[i]),
      ],
    ],
  );
}

Widget _buildText(
  BuildContext context,
  SduiNode node,
  List<Widget> children,
  VoidCallback? onAction,
) {
  final value = node.props['value'];

  if (value is! String || value.isEmpty) {
    return const SizedBox.shrink();
  }

  final typography = Theme.of(context).textTheme;

  final style = switch (node.props['style']) {
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

Widget _buildSpacer(
  BuildContext context,
  SduiNode node,
  List<Widget> children,
  VoidCallback? onAction,
) {
  return SizedBox(height: _spacing(node.props['size']));
}

Widget _buildButton(
  BuildContext context,
  SduiNode node,
  List<Widget> children,
  VoidCallback? onAction,
) {
  final label = node.props['label'];

  if (label is! String || label.isEmpty) {
    return const SizedBox.shrink();
  }

  return AppButton(label: label, onPressed: onAction);
}

double _spacing(dynamic value) {
  return switch (value) {
    'xs' => AppSpacing.xs,
    'sm' => AppSpacing.sm,
    'lg' => AppSpacing.lg,
    'xl' => AppSpacing.xl,
    _ => AppSpacing.md,
  };
}

List<Widget> _withSpacing(List<Widget> widgets, double gap) {
  return [
    for (var i = 0; i < widgets.length; i++) ...[
      if (i > 0) SizedBox(height: gap),
      widgets[i],
    ],
  ];
}
