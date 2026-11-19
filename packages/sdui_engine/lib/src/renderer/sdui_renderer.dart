import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

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
      _report(
        'unsupported_schema',
        'document',
        'schema',
        'Versão não suportada',
      );

      return fallback;
    }

    final widgets = <Widget>[];

    for (var i = 0; i < document.blocks.length; i++) {
      final widget = _renderNode(context, document.blocks[i], 'blocks[$i]');

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

  Widget? _renderNode(BuildContext context, SduiNode node, String path) {
    final builder = registry[node.type];

    if (builder == null) {
      _report(
        'unknown_component',
        path,
        node.type,
        'Componente não registrado',
      );
      return null;
    }

    final validationError = registry.validate(node);

    if (validationError != null) {
      _report('invalid_props', path, node.type, validationError);
      return null;
    }

    final children = <Widget>[];

    for (var i = 0; i < node.children.length; i++) {
      final child = _renderNode(
        context,
        node.children[i],
        '$path.children[$i]',
      );

      if (child != null) children.add(child);
    }

    final action = node.action;

    final onAction = action == null ? null : actionResolver(action);

    if (action != null && onAction == null) {
      _report(
        'unresolved_action',
        '$path.action',
        node.type,
        'Ação não reconhecida ou parâmetros inválidos',
      );
    }

    return builder(context, node, children, onAction);
  }

  void _report(String code, String path, String component, String reason) {
    if (!kDebugMode) return;

    // Evita mensagens excessivamente grandes vindas da API.
    final safeComponent = component.length > 60
        ? component.substring(0, 60)
        : component;

    debugPrint(
      '[SDUI][$code] $path '
      '($safeComponent): $reason',
    );
  }
}
