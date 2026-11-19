import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../data/account_repository.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    required this.repository,
    required this.onClose,
  });

  final AccountRepository repository;
  final VoidCallback onClose;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameEC = TextEditingController();
  final _emailEC = TextEditingController();
  final _passwordEC = TextEditingController();

  bool _loading = false;
  bool _completed = false;
  String? _error;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.repository.register(
        name: _nameEC.text.trim(),
        email: _emailEC.text.trim(),
        password: _passwordEC.text,
      );

      if (!mounted) return;
      setState(() => _completed = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Não foi possível simular o cadastro.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameEC.dispose();
    _emailEC.dispose();
    _passwordEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 72,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Cadastro simulado com sucesso!',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Seus dados não foram salvos. '
                  'Use a conta de demonstração para entrar.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Voltar ao login',
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: widget.onClose),
        title: const Text('Criar conta'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Crie sua conta',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameEC,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Informe seu nome'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailEC,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                    ),
                    validator: (v) => v == null || !v.contains('@')
                        ? 'Informe um e-mail válido'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordEC,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                    ),
                    validator: (v) => v == null || v.length < 6
                        ? 'Use pelo menos 6 caracteres'
                        : null,
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.primary),
              ),
            ],
            const SizedBox(height: 32),
            AppButton(
              label: _loading ? 'Enviando...' : 'Criar conta',
              onPressed: _loading ? null : _register,
            ),
          ],
        ),
      ),
    );
  }
}
