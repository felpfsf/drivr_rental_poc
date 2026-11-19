import 'package:core/core.dart';
import 'package:sdui_engine/sdui_engine.dart';

abstract interface class AccountSduiRepository {
  Future<SduiDocument> getProfileLayout();
}

class HttpAccountSduiRepository implements AccountSduiRepository {
  const HttpAccountSduiRepository(this._api);

  final ApiClient _api;

  @override
  Future<SduiDocument> getProfileLayout() async {
    final response = await _api.get(
      '/account/profile-layout',
    );

    return SduiParser.parse(
      Map<String, dynamic>.from(response as Map),
    );
  }
}
