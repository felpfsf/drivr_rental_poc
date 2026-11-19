import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

Dio createFakeDio({
  required int statusCode,
  required Object data,
}) {
  final dio = Dio(
    BaseOptions(baseUrl: 'http://localhost:3000'),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final response = Response<dynamic>(
          requestOptions: options,
          statusCode: statusCode,
          data: data,
        );

        if (statusCode >= 400) {
          return handler.reject(
            DioException(
              requestOptions: options,
              response: response,
              type: DioExceptionType.badResponse,
            ),
          );
        }

        handler.resolve(response);
      },
    ),
  );

  return dio;
}

void main() {
  group('ApiClient', () {
    test('retorna os dados quando recebe 200', () async {
      final api = ApiClient(
        baseUrl: 'http://localhost:3000',
        dio: createFakeDio(
          statusCode: 200,
          data: [
            {'id': 'car-001'},
          ],
        ),
      );

      final result = await api.get('/cars');

      expect(result, isA<List>());
      expect(result[0]['id'], 'car-001');

      api.close();
    });

    test('converte erro 500 em ApiException', () async {
      final api = ApiClient(
        baseUrl: 'http://localhost:3000',
        dio: createFakeDio(
          statusCode: 500,
          data: {
            'message': 'Erro interno simulado',
          },
        ),
      );

      await expectLater(
        api.get('/cars'),
        throwsA(
          isA<ApiException>()
              .having(
                (error) => error.statusCode,
                'statusCode',
                500,
              )
              .having(
                (error) => error.message,
                'message',
                'Erro interno simulado',
              ),
        ),
      );

      api.close();
    });
  });
}
