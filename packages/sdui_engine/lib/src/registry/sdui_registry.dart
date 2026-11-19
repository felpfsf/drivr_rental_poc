import 'package:flutter/widgets.dart';

import '../models/sdui_document.dart';

typedef SduiBlockBuilder = Widget Function(
  BuildContext context,
  SduiNode node,
  List<Widget> children,
  VoidCallback? onAction,
);

// Retorna null quando as propriedades são válidas.
// Caso contrário, retorna o motivo da rejeição.
typedef SduiNodeValidator = String? Function(SduiNode node);

class SduiRegistry {
  SduiRegistry(
    Map<String, SduiBlockBuilder> builders, {
    Map<String, SduiNodeValidator> validators = const {},
  }) : _builders = Map.unmodifiable(builders),
       _validators = Map.unmodifiable(validators);

  final Map<String, SduiBlockBuilder> _builders;
  final Map<String, SduiNodeValidator> _validators;

  SduiBlockBuilder? operator [](String type) {
    return _builders[type];
  }

  String? validate(SduiNode node) {
    return _validators[node.type]?.call(node);
  }

  SduiRegistry withComponents(Map<String, SduiBlockBuilder> components) {
    return SduiRegistry({..._builders, ...components}, validators: _validators);
  }

  SduiRegistry withValidators(Map<String, SduiNodeValidator> validators) {
    return SduiRegistry(_builders, validators: {..._validators, ...validators});
  }
}
