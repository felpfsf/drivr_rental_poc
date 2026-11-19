import 'package:material_ui/material_ui.dart';
import 'package:sdui_engine/sdui_engine.dart';

import 'account_sdui_section.dart';

class AccountProfileSduiSlot extends StatelessWidget {
  const AccountProfileSduiSlot({
    super.key,
    required this.layoutFuture,
    required this.onBenefitsRequested,
  });

  final Future<SduiDocument> layoutFuture;
  final VoidCallback onBenefitsRequested;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SduiDocument>(
      future: layoutFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 48,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          // SDUI é complementar ao perfil.
          return const SizedBox.shrink();
        }

        return AccountSduiSection(
          document: snapshot.data!,
          onBenefitsRequested: onBenefitsRequested,
        );
      },
    );
  }
}
