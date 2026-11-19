import 'package:account_mfe/src/domain/auth_models.dart';
import 'package:core/core.dart';

abstract interface class AccountRepository {
  Future<AuthSession> login({required String email, required String password});
  Future<void> register({
    required String name,
    required String email,
    required String password,
  });
  Future<AccountUser> getAccount();
}

class HttpAccountRepository implements AccountRepository {
  const HttpAccountRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      {
        'email': email,
        'password': password,
      },
    );

    return AuthSession.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _apiClient.post(
      '/auth/register',
      {
        'name': name,
        'email': email,
        'password': password,
      },
    );
  }

  @override
  Future<AccountUser> getAccount() async {
    final response = await _apiClient.get('/users/me');

    return AccountUser.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }
}
