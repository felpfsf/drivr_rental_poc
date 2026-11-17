import 'package:material_ui/material_ui.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline, size: 48),
          SizedBox(height: 16),
          Text('account_mfe'),
          SizedBox(height: 8),
          Text('Login e cadastro serão integrados ao Mockoon.'),
        ],
      ),
    );
  }
}
