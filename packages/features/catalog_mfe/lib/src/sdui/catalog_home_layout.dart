import 'package:sdui_engine/sdui_engine.dart';

class CatalogHomeLayout extends SduiDocument {
  const CatalogHomeLayout({
    required super.schemaVersion,
    required super.blocks,
  });

  factory CatalogHomeLayout.fromJson(
    Map<String, dynamic> json,
  ) {
    final document = SduiParser.parse(json);

    return CatalogHomeLayout(
      schemaVersion: document.schemaVersion,
      blocks: document.blocks,
    );
  }
}
