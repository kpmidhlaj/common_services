// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:common_services/api_services/api_service.dart' as _i136;
import 'package:common_services/fcm_service/fcm_service.dart' as _i95;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i95.FCMService>(() => _i95.FCMService());
    gh.factoryParam<_i136.Api, String, dynamic>((
      baseUrl,
      _,
    ) =>
        _i136.Api(baseUrl));
    return this;
  }
}
