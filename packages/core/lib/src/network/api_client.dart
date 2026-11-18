import 'package:dio/dio.dart';

import 'api_exception.dart';

class ApiClient {
  ApiClient({
    required String baseUrl,
    Dio? dio,
    String? Function()? tokenProvider,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl.replaceFirst(RegExp(r'/+$'), ''),
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 10),
               sendTimeout: const Duration(seconds: 10),
               contentType: Headers.jsonContentType,
               responseType: ResponseType.json,
             ),
           ) {
    if (tokenProvider != null) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final token = tokenProvider();

            if (token != null &&
                token.isNotEmpty &&
                !options.path.startsWith('/auth/')) {
              options.headers['Authorization'] = 'Bearer $token';
            }

            handler.next(options);
          },
        ),
      );
    }
  }

  final Dio _dio;

  Future<dynamic> get(String path) {
    return _request(() => _dio.get<dynamic>(path));
  }

  Future<dynamic> post(
    String path,
    Map<String, dynamic> body,
  ) {
    return _request(
      () => _dio.post<dynamic>(
        path,
        data: body,
      ),
    );
  }

  Future<dynamic> _request(
    Future<Response<dynamic>> Function() operation,
  ) async {
    try {
      final response = await operation();
      return response.data;
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  ApiException _mapException(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    final data = error.response?.data;

    if (error.response != null) {
      final message = data is Map && data['message'] is String
          ? data['message'] as String
          : 'Erro na comunicação com a API';

      return ApiException(statusCode, message);
    }

    final message = switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => 'Tempo limite da requisição excedido',

      DioExceptionType.connectionError =>
        'Não foi possível conectar ao servidor',

      DioExceptionType.cancel => 'Requisição cancelada',

      _ => 'Erro inesperado de comunicação',
    };

    return ApiException(statusCode, message);
  }

  void close() => _dio.close(force: true);
}
