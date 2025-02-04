import 'package:common_services/di/injectable.config.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../api_services/api_service.dart';

final getIt = GetIt.instance;

@injectableInit
void configureDependencies() {
  getIt.init();
}

void registerApiService(String baseUrl) {
  getIt.registerFactory<Api>(() => Api(baseUrl));
}
