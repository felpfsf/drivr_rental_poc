import 'package:account_mfe/account_mfe.dart';
import 'package:booking_mfe/booking_mfe.dart';
import 'package:catalog_mfe/catalog_mfe.dart';
import 'package:go_router/go_router.dart';
import 'package:shell_app/app_shell.dart';

final appRouter = GoRouter(
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
              builder: (context, state) => const AccountPage(),
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
          onClose: () => context.pop(),
        );
      },
    ),
  ],
);
