import '../models/sdui_document.dart';

abstract final class SduiParser {
  static const maxDepth = 5;
  static const maxNodes = 50;

  static SduiDocument parse(Map<String, dynamic> json) {
    final version = json['schemaVersion'];
    final rawBlocks = json['blocks'];

    if (version is! int || rawBlocks is! List) {
      throw const FormatException('Invalid SDUI payload');
    }

    final budget = _ParseBudget();
    final blocks = <SduiNode>[];

    for (final raw in rawBlocks) {
      final node = _parseNode(raw, 0, budget);
      if (node != null) blocks.add(node);
    }

    return SduiDocument(
      schemaVersion: version,
      blocks: List.unmodifiable(blocks),
    );
  }

  static SduiNode? _parseNode(dynamic raw, int depth, _ParseBudget budget) {
    if (depth >= maxDepth) {
      throw const FormatException('SDUI maximum depth exceeded');
    }

    if (raw is! Map) return null;

    final json = Map<String, dynamic>.from(raw);
    final type = json['type'];

    if (type is! String || type.trim().isEmpty) {
      return null;
    }

    budget.count++;

    if (budget.count > maxNodes) {
      throw const FormatException('SDUI maximum node count exceeded');
    }

    final rawProps = json['props'];

    final props = rawProps is Map
        ? Map<String, dynamic>.from(rawProps)
        : <String, dynamic>{};

    final rawChildren = json['children'];

    if (rawChildren != null && rawChildren is! List) {
      throw const FormatException('SDUI children must be a list');
    }

    final children = <SduiNode>[];

    if (rawChildren is List) {
      for (final child in rawChildren) {
        final node = _parseNode(child, depth + 1, budget);

        if (node != null) children.add(node);
      }
    }

    SduiAction? action;
    final rawAction = json['action'];

    if (rawAction is Map) {
      final actionJson = Map<String, dynamic>.from(rawAction);

      final actionType = actionJson['type'];

      if (actionType is String && actionType.trim().isNotEmpty) {
        action = SduiAction(
          type: actionType,
          params: Map.unmodifiable(actionJson),
        );
      }
    }

    return SduiNode(
      type: type,
      props: Map.unmodifiable(props),
      children: List.unmodifiable(children),
      action: action,
    );
  }
}

class _ParseBudget {
  int count = 0;
}
