import 'package:catalog_mfe/catalog_mfe.dart';
import 'package:catalog_mfe/src/sdui/catalog_sdui_renderer.dart';
import 'package:material_ui/material_ui.dart';

class CatalogHomeSlot extends StatelessWidget {
  const CatalogHomeSlot({
    super.key,
    required this.layoutFuture,
    required this.onCarSelected,
  });

  final Future<CatalogHomeLayout> layoutFuture;
  final ValueChanged<String> onCarSelected;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CatalogHomeLayout>(
      future: layoutFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 60,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Text(
            'Explore nossos veículos disponíveis',
            style: Theme.of(context).textTheme.titleLarge,
          );
        }

        return CatalogSduiRenderer(
          layout: snapshot.data!,
          onCarSelected: onCarSelected,
        );
      },
    );
  }
}
