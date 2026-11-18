import 'package:account_mfe/account_mfe.dart';
import 'package:flutter/foundation.dart';

class SessionController extends ChangeNotifier {
  AuthSession? _session;

  bool get isAuthenticated => _session != null;

  String? get accessToken => _session?.accessToken;

  AccountUser? get user => _session?.user;

  void login(AuthSession session) {
    _session = session;
    notifyListeners();
  }

  void logout() {
    _session = null;
    notifyListeners();
  }
}
