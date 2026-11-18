class CatalogHomeLayout {
  const CatalogHomeLayout({
    required this.schemaVersion,
    required this.blocks,
  });

  static const maxDepth = 5;
  static const maxNodes = 50;

  final int schemaVersion;
  final List<CatalogUiBlock> blocks;

  factory CatalogHomeLayout.fromJson(
    Map<String, dynamic> json,
  ) {
    final version = json['schemaVersion'];
    final rawBlocks = json['blocks'];

    if (version is! int || rawBlocks is! List) {
      throw const FormatException('Invalid SDUI payload');
    }

    final budget = _NodeBudget();
    final blocks = <CatalogUiBlock>[];

    for (final raw in rawBlocks) {
      final block = _parseBlock(raw, 0, budget);
      if (block != null) blocks.add(block);
    }

    return CatalogHomeLayout(
      schemaVersion: version,
      blocks: blocks,
    );
  }

  static CatalogUiBlock? _parseBlock(
    dynamic raw,
    int depth,
    _NodeBudget budget,
  ) {
    if (depth >= maxDepth) {
      throw const FormatException(
        'SDUI maximum depth exceeded',
      );
    }

    if (raw is! Map) return null;

    final json = Map<String, dynamic>.from(raw);
    final type = json['type'];

    if (type is! String || type.isEmpty) return null;

    budget.count++;

    if (budget.count > maxNodes) {
      throw const FormatException(
        'SDUI maximum node count exceeded',
      );
    }

    final rawProps = json['props'];
    final props = rawProps is Map
        ? Map<String, dynamic>.from(rawProps)
        : <String, dynamic>{};

    final children = <CatalogUiBlock>[];
    final rawChildren = json['children'];

    if (rawChildren != null && rawChildren is! List) {
      throw const FormatException(
        'SDUI children must be a list',
      );
    }

    if (rawChildren is List) {
      for (final child in rawChildren) {
        final parsed = _parseBlock(
          child,
          depth + 1,
          budget,
        );

        if (parsed != null) children.add(parsed);
      }
    }

    CatalogUiAction? action;
    final rawAction = json['action'];

    if (rawAction is Map) {
      final actionJson = Map<String, dynamic>.from(rawAction);
      final actionType = actionJson['type'];

      if (actionType is String) {
        action = CatalogUiAction(
          type: actionType,
          carId: actionJson['carId'] is String
              ? actionJson['carId'] as String
              : null,
        );
      }
    }

    return CatalogUiBlock(
      type: type,
      props: props,
      children: children,
      action: action,
    );
  }
}

class _NodeBudget {
  int count = 0;
}

class CatalogUiBlock {
  const CatalogUiBlock({
    required this.type,
    required this.props,
    this.children = const [],
    this.action,
  });

  final String type;
  final Map<String, dynamic> props;
  final List<CatalogUiBlock> children;
  final CatalogUiAction? action;
}

class CatalogUiAction {
  const CatalogUiAction({
    required this.type,
    this.carId,
  });

  final String type;
  final String? carId;
}
