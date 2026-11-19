import 'package:flutter/widgets.dart';

import '../models/sdui_document.dart';

typedef SduiBlockBuilder = Widget Function(
  BuildContext context,
  SduiNode node,
  List<Widget> children,
  VoidCallback? onAction,
);

class SduiRegistry {
  SduiRegistry(Map<String, SduiBlockBuilder> builders)
    : _builders = Map.unmodifiable(builders);

  final Map<String, SduiBlockBuilder> _builders;

  SduiBlockBuilder? operator [](String type) {
    return _builders[type];
  }

  SduiRegistry withComponents(Map<String, SduiBlockBuilder> components) {
    return SduiRegistry({..._builders, ...components});
  }
}
