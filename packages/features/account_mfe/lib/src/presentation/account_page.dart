import 'package:account_mfe/account_mfe.dart';
import 'package:account_mfe/src/presentation/widgets/account_profile_sdui_slot.dart';
import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sdui_engine/sdui_engine.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({
    super.key,
    required this.onLoginRequested,
  });

  final VoidCallback onLoginRequested;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline, size: 64),
            const SizedBox(height: 16),
            const Text('Acesse sua conta DrivR'),
            const SizedBox(height: 24),
            AppButton(
              label: 'Entrar',
              onPressed: onLoginRequested,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.repository,
    required this.layoutRepository,
    required this.onLogout,
  });

  final AccountRepository repository;
  final AccountSduiRepository layoutRepository;
  final VoidCallback onLogout;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<AccountUser> _profileFuture;
  late Future<SduiDocument> _layoutFuture;

  @override
  void initState() {
    super.initState();

    _profileFuture = widget.repository.getAccount();

    _layoutFuture = widget.layoutRepository.getProfileLayout();
  }

  void _showBenefits() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Benefícios DrivR'),
          content: const Text(
            'Esta é uma experiência demonstrativa '
            'controlada por Server-Driven UI.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AccountUser>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: TextButton(
              onPressed: widget.onLogout,
              child: const Text('Erro ao carregar perfil. Sair'),
            ),
          );
        }

        final user = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const SizedBox(height: 32),
            const CircleAvatar(
              radius: 36,
              child: Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              user.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xl),

            AccountProfileSduiSlot(
              layoutFuture: _layoutFuture,
              onBenefitsRequested: _showBenefits,
            ),

            const SizedBox(height: AppSpacing.xl),

            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: widget.onLogout,
              child: const Text('Sair da conta'),
            ),
          ],
        );
      },
    );
  }
}
