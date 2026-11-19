import 'package:account_mfe/src/presentation/widgets/account_sdui_section.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sdui_engine/sdui_engine.dart';

void main() {
  testWidgets(
    'renderiza componente próprio e executa ação',
    (tester) async {
      final document = SduiParser.parse({
        'schemaVersion': 2,
        'blocks': [
          {
            'type': 'account_benefits_banner',
            'props': {
              'title': 'Benefícios DrivR',
              'buttonLabel': 'Saiba mais',
            },
            'action': {
              'type': 'show_benefit_details',
            },
          },
        ],
      });

      var actionRequested = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: Scaffold(
            body: AccountSduiSection(
              document: document,
              onBenefitsRequested: () {
                actionRequested = true;
              },
            ),
          ),
        ),
      );

      expect(
        find.text('Benefícios DrivR'),
        findsOneWidget,
      );

      await tester.tap(find.text('Saiba mais'));

      expect(actionRequested, isTrue);
    },
  );

  testWidgets(
    'não executa ações de outros domínios',
    (tester) async {
      final document = SduiParser.parse({
        'schemaVersion': 2,
        'blocks': [
          {
            'type': 'account_benefits_banner',
            'props': {
              'title': 'Benefícios DrivR',
              'buttonLabel': 'Saiba mais',
            },
            'action': {
              'type': 'open_car',
              'carId': 'car-001',
            },
          },
        ],
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccountSduiSection(
              document: document,
              onBenefitsRequested: () {},
            ),
          ),
        ),
      );

      expect(
        find.text('Benefícios DrivR'),
        findsOneWidget,
      );

      // Sem ação reconhecida, não existe CTA ativo.
      expect(find.text('Saiba mais'), findsNothing);
    },
  );
}
