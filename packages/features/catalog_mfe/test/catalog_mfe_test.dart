import 'package:catalog_mfe/catalog_mfe.dart';
import 'package:catalog_mfe/src/models/drivr_rental_car.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('shows car details returned by repository', (tester) async {
    final repository = _CatalogRepositoryStub(
      const DrivrRentalCar(
        id: 'car-001',
        brand: 'Marca da API',
        model: 'Modelo da API',
        dailyPrice: 777,
        topSpeedKmh: 300,
        accelerationSeconds: 3.2,
        horsePower: 500,
        fuel: 'Elétrico',
        transmission: 'Automático',
        seats: 2,
        description: 'Descrição da API',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('pt', 'BR')],
        home: CarDetailsPage(
          carId: 'car-001',
          onBack: () {},
          onBookingRequested: (_) {},
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.requestedId, 'car-001');
    expect(find.text('Modelo da API'), findsOneWidget);
    expect(find.text('R\$ 777'), findsOneWidget);
    expect(find.text('RS 5 Coupé'), findsNothing);
  });
}

class _CatalogRepositoryStub implements CatalogRepository {
  _CatalogRepositoryStub(this.car);

  final DrivrRentalCar? car;
  String? requestedId;

  @override
  Future<List<DrivrRentalCar>> getCars() async {
    throw UnimplementedError();
  }

  @override
  Future<CatalogHomeLayout> getHomeLayout() async {
    throw UnimplementedError();
  }

  @override
  Future<DrivrRentalCar?> getCarById(String id) async {
    requestedId = id;
    return car;
  }
}
