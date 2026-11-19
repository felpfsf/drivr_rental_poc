import 'package:account_mfe/account_mfe.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingApiClient extends ApiClient {
  _RecordingApiClient() : super(baseUrl: 'http://localhost:3000');

  String? lastGetPath;
  String? lastPostPath;
  Map<String, dynamic>? lastBody;
  Object? response;

  @override
  Future<dynamic> get(String path) async {
    lastGetPath = path;
    return response;
  }

  @override
  Future<dynamic> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    lastPostPath = path;
    lastBody = body;
    return response;
  }
}

void main() {
  group('HttpAccountRepository', () {
    test('logs in and maps session response', () async {
      final api = _RecordingApiClient()
        ..response = {
          'accessToken': 'test-token',
          'user': {
            'id': 'user-001',
            'name': 'Ana Silva',
            'email': 'ana@example.com',
          },
        };
      addTearDown(api.close);

      final session = await HttpAccountRepository(api).login(
        email: 'ana@example.com',
        password: 'secret123',
      );

      expect(api.lastPostPath, '/auth/login');
      expect(api.lastBody, {
        'email': 'ana@example.com',
        'password': 'secret123',
      });
      expect(session.accessToken, 'test-token');
      expect(session.user.name, 'Ana Silva');
    });

    test('registers account with submitted fields', () async {
      final api = _RecordingApiClient();
      addTearDown(api.close);

      await HttpAccountRepository(api).register(
        name: 'Ana Silva',
        email: 'ana@example.com',
        password: 'secret123',
      );

      expect(api.lastPostPath, '/auth/register');
      expect(api.lastBody, {
        'name': 'Ana Silva',
        'email': 'ana@example.com',
        'password': 'secret123',
      });
    });

    test('loads current account and maps profile response', () async {
      final api = _RecordingApiClient()
        ..response = {
          'id': 'user-001',
          'name': 'Ana Silva',
          'email': 'ana@example.com',
        };
      addTearDown(api.close);

      final account = await HttpAccountRepository(api).getAccount();

      expect(api.lastGetPath, '/users/me');
      expect(account.id, 'user-001');
      expect(account.email, 'ana@example.com');
    });
  });
}
