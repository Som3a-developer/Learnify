import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioHelper {
  static Dio? _dio;
  DioHelper._();

  static void init() {
    if (_dio != null) return;

    final baseUrl = dotenv.env['DATA_URL'];
    final apiKey = dotenv.env['SUPABASE_KEY'];

    if (baseUrl == null || apiKey == null) {
      throw Exception("Missing DATA_URL or SUPABASE_KEY in .env file");
    }

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'apikey': apiKey,
        'Authorization': 'Bearer $apiKey',
      },
    ));

    _dio!.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  static Future<Response> getData({
    required String path,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio!.get(path, queryParameters: queryParameters);
  }

  static Future<Response> postData({
    required String path,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    return await _dio!.post(path, queryParameters: queryParameters, data: body);
  }

  static Future<Response> deleteData({
    required String path,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    return await _dio!
        .delete(path, queryParameters: queryParameters, data: body);
  }

  static Future<Response> patchData({
    required String path,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    return await _dio!
        .patch(path, queryParameters: queryParameters, data: body);
  }

  static Future<Response> putData({
    required String path,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    return await _dio!.put(path, queryParameters: queryParameters, data: body);
  }
}
