import 'package:dio/dio.dart';

import '../../storage_services/local_storage_services.dart';
import '../../storage_services/storage_constants.dart';
import '../utils/api_logger.dart';

class ProfileApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    super.onRequest(options, handler);
    try {
      String? accessToken = LocalStorage.getString(StorageKey.accessToken);
      if (accessToken == null) {
        handler.reject(DioException(requestOptions: options), true);
      } else {
        options.headers['Authorization'] = 'Bearer $accessToken';
        // options.headers['Tokenvalid'] = environment.apiToken;
        options.headers['Accept'] = 'application/json';
        options.headers['Content-Type'] = 'application/json';
        handler.next(options);
      }
    } on StateError {
      /// Do nothing.
    } catch (e) {
      handler.reject(DioException(requestOptions: options), true);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
    ApiLogger().logSuccessResponse(response);
  }
}
