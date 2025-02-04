import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'interceptors/error_api_interceptor.dart';
import 'interceptors/general_api_interceptor.dart';
import 'interceptors/profile_api_interceptor.dart';

@injectable
class Api {
  final Dio profile;
  final Dio general;

  Api(@factoryParam String baseUrl)
      : profile = _createDio(baseUrl: baseUrl, hasAuth: true),
        general = _createDio(baseUrl: baseUrl, hasAuth: false);

  static Dio _createDio({required String baseUrl, required bool hasAuth}) {
    var dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        receiveTimeout: const Duration(seconds: 30),
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    if (hasAuth) {
      dio.interceptors.addAll([ProfileApiInterceptor(), ErrorApiInterceptor()]);
    } else {
      dio.interceptors.addAll([GeneralApiInterceptor(), ErrorApiInterceptor()]);
    }

    return dio;
  }
}
