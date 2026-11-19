import 'package:account_mfe/account_mfe.dart';
import 'package:booking_mfe/booking_mfe.dart';
import 'package:catalog_mfe/catalog_mfe.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shell_app/app_shell.dart';
import 'package:shell_app/session_controller.dart';

GoRouter createAppRouter({
  required CatalogRepository catalogRepository,
  required BookingRepository bookingRepository,
  required AccountRepository accountRepository,
  required AccountSduiRepository accountSduiRepository,
  required SessionController session,
}) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => CatalogPage(
                  repository: catalogRepository,
                  title: 'Início',
                  onCarSelected: (carId) {
                    context.push('/cars/$carId');
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cars',
                builder: (context, state) => CatalogPage(
                  repository: catalogRepository,
                  title: 'Buscar carros',
                  onCarSelected: (carId) {
                    context.push('/cars/$carId');
                  },
                ),
              ),
              GoRoute(
                path: '/cars/:carId',
                builder: (context, state) {
                  final carId = state.pathParameters['carId']!;

                  return CarDetailsPage(
                    repository: catalogRepository,
                    carId: carId,
                    onBack: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/cars');
                      }
                    },
                    onBookingRequested: (id) {
                      context.push('/bookings/new/$id');
                    },
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                builder: (context, state) {
                  return ListenableBuilder(
                    listenable: session,
                    builder: (context, child) {
                      if (session.isAuthenticated) {
                        return ProfilePage(
                          repository: accountRepository,
                          layoutRepository: accountSduiRepository,
                          onLogout: session.logout,
                        );
                      }

                      return AccountPage(
                        onLoginRequested: () {
                          context.push('/account/login');
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/bookings/new/:carId',
        builder: (context, state) {
          final carId = state.pathParameters['carId']!;

          return BookingPage(
            carId: carId,
            repository: bookingRepository,
            onClose: () => context.pop(),
            ensureAuthenticated: () async {
              if (session.isAuthenticated) return true;

              final authenticated = await context.push<bool>('/account/login');

              return authenticated == true && session.isAuthenticated;
            },
          );
        },
      ),

      GoRoute(
        path: '/account/login',
        builder: (context, state) {
          return LoginPage(
            repository: accountRepository,
            onAuthenticated: (auth) {
              session.login(auth);
              context.pop(true);
            },
            onRegisterRequested: () {
              context.push('/account/register');
            },
            onClose: () => context.pop(false),
          );
        },
      ),
      GoRoute(
        path: '/account/register',
        builder: (context, state) {
          return RegisterPage(
            repository: accountRepository,
            onClose: () => context.pop(),
          );
        },
      ),
    ],
  );
}
