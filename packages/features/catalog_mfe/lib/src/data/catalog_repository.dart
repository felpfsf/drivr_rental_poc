import 'package:catalog_mfe/src/sdui/catalog_home_layout.dart';
import 'package:core/core.dart';

import '../models/drivr_rental_car.dart';

abstract interface class CatalogRepository {
  Future<List<DrivrRentalCar>> getCars();

  Future<DrivrRentalCar?> getCarById(String id);

  Future<CatalogHomeLayout> getHomeLayout();
}

class HttpCatalogRepository implements CatalogRepository {
  const HttpCatalogRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<DrivrRentalCar>> getCars() async {
    final response = await _api.get('/cars');

    if (response is! List) {
      throw const FormatException('Lista de veículos inválida');
    }

    return response
        .map(
          (item) => DrivrRentalCar.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  @override
  Future<DrivrRentalCar?> getCarById(String id) async {
    try {
      final response = await _api.get(
        '/cars/${Uri.encodeComponent(id)}',
      );

      return DrivrRentalCar.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    } on ApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<CatalogHomeLayout> getHomeLayout() async {
    final response = await _api.get('/catalog/home-layout');

    return CatalogHomeLayout.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }
}
