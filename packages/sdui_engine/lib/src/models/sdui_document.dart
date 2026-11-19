class SduiDocument {
  const SduiDocument({required this.schemaVersion, required this.blocks});

  final int schemaVersion;
  final List<SduiNode> blocks;
}

class SduiNode {
  const SduiNode({
    required this.type,
    this.props = const {},
    this.children = const [],
    this.action,
  });

  final String type;
  final Map<String, dynamic> props;
  final List<SduiNode> children;
  final SduiAction? action;
}

class SduiAction {
  const SduiAction({required this.type, required this.params});

  final String type;
  final Map<String, dynamic> params;
}
