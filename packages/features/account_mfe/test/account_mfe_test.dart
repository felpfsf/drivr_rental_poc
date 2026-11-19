import 'package:account_mfe/account_mfe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _testUser = AccountUser(
  id: 'user-001',
  name: 'Ana Silva',
  email: 'ana@example.com',
);

const _testSession = AuthSession(
  accessToken: 'test-token',
  user: _testUser,
);

void main() {
  group('AccountPage', () {
    testWidgets('requests login when user taps Entrar', (tester) async {
      var loginRequested = false;

      await tester.pumpWidget(
        _app(
          AccountPage(
            onLoginRequested: () => loginRequested = true,
          ),
        ),
      );

      await tester.tap(find.text('Entrar'));

      expect(loginRequested, isTrue);
    });
  });

  group('LoginPage', () {
    testWidgets('submits trimmed credentials and returns session', (
      tester,
    ) async {
      final repository = _AccountRepositoryFake(session: _testSession);
      AuthSession? authenticatedSession;

      await tester.pumpWidget(
        _app(
          LoginPage(
            repository: repository,
            onAuthenticated: (session) => authenticatedSession = session,
            onRegisterRequested: () {},
            onClose: () {},
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        ' ana@example.com ',
      );
      await tester.enterText(find.byType(TextFormField).at(1), ' secret123 ');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(repository.loginCalls, 1);
      expect(repository.loginEmail, 'ana@example.com');
      expect(repository.loginPassword, 'secret123');
      expect(authenticatedSession, same(_testSession));
    });

    testWidgets('validates credentials before calling repository', (
      tester,
    ) async {
      final repository = _AccountRepositoryFake();

      await tester.pumpWidget(
        _app(
          LoginPage(
            repository: repository,
            onAuthenticated: (_) {},
            onRegisterRequested: () {},
            onClose: () {},
          ),
        ),
      );

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Por favor, insira seu email'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
      expect(repository.loginCalls, 0);
    });

    testWidgets('shows error when authentication fails', (tester) async {
      final repository = _AccountRepositoryFake(
        loginError: Exception('unauthorized'),
      );

      await tester.pumpWidget(
        _app(
          LoginPage(
            repository: repository,
            onAuthenticated: (_) {},
            onRegisterRequested: () {},
            onClose: () {},
          ),
        ),
      );
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'ana@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Não foi possível entrar. Confira suas credenciais.'),
        findsOneWidget,
      );
    });
  });

  group('RegisterPage', () {
    testWidgets('registers user and shows success state', (tester) async {
      final repository = _AccountRepositoryFake();
      var closeRequested = false;

      await tester.pumpWidget(
        _app(
          RegisterPage(
            repository: repository,
            onClose: () => closeRequested = true,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), ' Ana Silva ');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        ' ana@example.com ',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'secret123');
      await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));
      await tester.pumpAndSettle();

      expect(repository.registerCalls, 1);
      expect(repository.registeredName, 'Ana Silva');
      expect(repository.registeredEmail, 'ana@example.com');
      expect(repository.registeredPassword, 'secret123');
      expect(find.text('Cadastro simulado com sucesso!'), findsOneWidget);

      await tester.tap(find.text('Voltar ao login'));
      expect(closeRequested, isTrue);
    });

    testWidgets('shows error when registration fails', (tester) async {
      final repository = _AccountRepositoryFake(
        registerError: Exception('conflict'),
      );

      await tester.pumpWidget(
        _app(
          RegisterPage(
            repository: repository,
            onClose: () {},
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'Ana Silva');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'ana@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'secret123');
      await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));
      await tester.pumpAndSettle();

      expect(
        find.text('Não foi possível simular o cadastro.'),
        findsOneWidget,
      );
    });
  });

  group('ProfilePage', () {
    testWidgets('shows account data and handles logout', (tester) async {
      final repository = _AccountRepositoryFake(account: _testUser);
      var logoutRequested = false;

      await tester.pumpWidget(
        _app(
          ProfilePage(
            repository: repository,
            onLogout: () => logoutRequested = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ana Silva'), findsOneWidget);
      expect(find.text('ana@example.com'), findsOneWidget);

      await tester.tap(find.text('Sair da conta'));
      expect(logoutRequested, isTrue);
    });

    testWidgets('offers logout when account loading fails', (tester) async {
      final repository = _AccountRepositoryFake(
        accountError: Exception('unavailable'),
      );
      var logoutRequested = false;

      await tester.pumpWidget(
        _app(
          ProfilePage(
            repository: repository,
            onLogout: () => logoutRequested = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Erro ao carregar perfil. Sair'),
        findsOneWidget,
      );
      await tester.tap(find.text('Erro ao carregar perfil. Sair'));

      expect(logoutRequested, isTrue);
    });
  });
}

Widget _app(Widget home) {
  return MaterialApp(
    theme: ThemeData(splashFactory: NoSplash.splashFactory),
    home: home,
  );
}

class _AccountRepositoryFake implements AccountRepository {
  _AccountRepositoryFake({
    this.session,
    this.account,
    this.loginError,
    this.registerError,
    this.accountError,
  });

  final AuthSession? session;
  final AccountUser? account;
  final Object? loginError;
  final Object? registerError;
  final Object? accountError;

  var loginCalls = 0;
  var registerCalls = 0;
  String? loginEmail;
  String? loginPassword;
  String? registeredName;
  String? registeredEmail;
  String? registeredPassword;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    loginEmail = email;
    loginPassword = password;

    if (loginError case final error?) throw error;
    if (session case final value?) return value;
    throw StateError('Test session was not configured');
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    registerCalls++;
    registeredName = name;
    registeredEmail = email;
    registeredPassword = password;

    if (registerError case final error?) throw error;
  }

  @override
  Future<AccountUser> getAccount() async {
    if (accountError case final error?) throw error;
    if (account case final value?) return value;
    throw StateError('Test account was not configured');
  }
}
