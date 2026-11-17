import 'package:account_mfe/account_mfe.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows account placeholder', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AccountPage()));

    expect(find.text('account_mfe'), findsOneWidget);
    expect(
      find.text('Login e cadastro serão integrados ao Mockoon.'),
      findsOneWidget,
    );
  });
}
