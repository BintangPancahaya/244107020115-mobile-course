import 'package:dio/dio.dart';

/// Konfigurasi HTTP terpusat di data layer (bukan di widget/provider).
Dio buildPostsHttpClient() => Dio(BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
