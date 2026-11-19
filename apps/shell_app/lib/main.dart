import 'package:account_mfe/account_mfe.dart';
import 'package:booking_mfe/booking_mfe.dart';
import 'package:catalog_mfe/catalog_mfe.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shell_app/session_controller.dart';

import 'app_router.dart';

void main() {
  runApp(const RentalApp());
}

class RentalApp extends StatefulWidget {
  const RentalApp({
    super.key,
    this.catalogRepository,
    this.bookingRepository,
  });

  final CatalogRepository? catalogRepository;
  final BookingRepository? bookingRepository;

  @override
  State<RentalApp> createState() => _RentalAppState();
}

class _RentalAppState extends State<RentalApp> {
  late final SessionController _session = SessionController();

  late final ApiClient _api = ApiClient(
    baseUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:3000',
    ),
    tokenProvider: () => _session.accessToken,
  );

  late final AccountRepository _accountRepository = HttpAccountRepository(_api);
  late final AccountSduiRepository _accountSduiRepository =
      HttpAccountSduiRepository(_api);
  late final GoRouter _router = createAppRouter(
    catalogRepository: widget.catalogRepository ?? HttpCatalogRepository(_api),
    bookingRepository: widget.bookingRepository ?? HttpBookingRepository(_api),
    accountRepository: _accountRepository,
    accountSduiRepository: _accountSduiRepository,
    session: _session,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Drivr POC',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.light,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _api.close();
    _session.dispose();
    super.dispose();
  }
}
