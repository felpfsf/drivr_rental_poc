import 'package:account_mfe/src/data/account_repository.dart';
import 'package:account_mfe/src/domain/auth_models.dart';
import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.repository,
    required this.onAuthenticated,
    required this.onRegisterRequested,
    required this.onClose,
  });

  final AccountRepository repository;
  final ValueChanged<AuthSession> onAuthenticated;
  final VoidCallback onRegisterRequested;
  final VoidCallback onClose;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailEC = TextEditingController();
  final _passwordEC = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final session = await widget.repository.login(
        email: _emailEC.text.trim(),
        password: _passwordEC.text.trim(),
      );

      if (!mounted) return;

      widget.onAuthenticated(session);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Não foi possível entrar. Confira suas credenciais.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: widget.onClose),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Bem-vindo ao DrivR',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text('Entre para continuar sua experiência.'),
            const SizedBox(height: AppSpacing.xl),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailEC,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Por favor, insira seu email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _passwordEC,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira sua senha';
                      }
                      return null;
                    },
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: _isLoading ? 'Entrando...' : 'Entrar',
                    onPressed: _isLoading ? null : _login,
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : widget.onRegisterRequested,
                    child: const Text('Criar conta'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailEC.dispose();
    _passwordEC.dispose();
    super.dispose();
  }
}
