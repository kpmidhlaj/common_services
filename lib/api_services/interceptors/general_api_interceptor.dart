import 'package:dio/dio.dart';

import '../utils/api_logger.dart';

class GeneralApiInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
    ApiLogger().logSuccessResponse(response);
  }
}
