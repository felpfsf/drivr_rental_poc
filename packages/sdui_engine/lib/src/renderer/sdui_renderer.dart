import 'package:flutter/widgets.dart';

import '../models/sdui_document.dart';
import '../registry/sdui_registry.dart';

typedef SduiActionResolver = VoidCallback? Function(SduiAction action);

class SduiRenderer extends StatelessWidget {
  const SduiRenderer({
    super.key,
    required this.document,
    required this.registry,
    required this.actionResolver,
    this.fallback = const SizedBox.shrink(),
    this.supportedVersions = const {1, 2},
  });

  final SduiDocument document;
  final SduiRegistry registry;
  final SduiActionResolver actionResolver;
  final Widget fallback;
  final Set<int> supportedVersions;

  @override
  Widget build(BuildContext context) {
    if (!supportedVersions.contains(document.schemaVersion)) {
      return fallback;
    }

    final widgets = <Widget>[];

    for (final node in document.blocks) {
      final widget = _renderNode(context, node);

      if (widget != null) widgets.add(widget);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < widgets.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          widgets[i],
        ],
      ],
    );
  }

  Widget? _renderNode(BuildContext context, SduiNode node) {
    final builder = registry[node.type];

    if (builder == null) return null;

    final children = <Widget>[];

    for (final child in node.children) {
      final widget = _renderNode(context, child);

      if (widget != null) children.add(widget);
    }

    final action = node.action;

    return builder(
      context,
      node,
      children,
      action == null ? null : actionResolver(action),
    );
  }
}
