import 'package:dio/dio.dart';

class BadRequestException extends DioException {
  BadRequestException({required super.requestOptions, super.error});

  @override
  String toString() {
    return error?.toString() ?? 'Invalid request';
  }
}

class TooManyRequestException extends DioException {
  TooManyRequestException({required super.requestOptions});

  @override
  String toString() {
    return "Too many requests! Please try again.";
  }
}

class InternalServerErrorException extends DioException {
  InternalServerErrorException({required super.requestOptions});

  @override
  String toString() {
    return 'Unknown error occurred, please try again later.';
  }
}

class ConflictException extends DioException {
  ConflictException({required super.requestOptions});

  @override
  String toString() {
    return 'Conflict occurred';
  }
}

class UnauthorizedException extends DioException {
  UnauthorizedException({required super.requestOptions, super.error});

  @override
  String toString() {
    return error?.toString() ?? 'Access denied';
  }
}

class NotFoundException extends DioException {
  NotFoundException({required super.requestOptions});

  @override
  String toString() {
    return 'The requested information could not be found';
  }
}

class ForbiddenException extends DioException {
  ForbiddenException({required super.requestOptions});

  @override
  String toString() {
    return 'Access to the resource is forbidden';
  }
}

class ServiceUnavailableException extends DioException {
  ServiceUnavailableException({required super.requestOptions});

  @override
  String toString() {
    return 'The service is currently unavailable';
  }
}

class NoInternetConnectionException extends DioException {
  NoInternetConnectionException({required super.requestOptions});

  @override
  String toString() {
    return 'An unexpected response received from the server.';
  }
}

class DeadlineExceededException extends DioException {
  DeadlineExceededException({required super.requestOptions});

  @override
  String toString() {
    return 'The connection has timed out, please try again.';
  }
}

class RequestCancelledException extends DioException {
  RequestCancelledException({required super.requestOptions});

  @override
  String toString() {
    return 'The request has been cancelled, please try again.';
  }
}

class UnknownErrorException extends DioException {
  UnknownErrorException({required super.requestOptions, super.response, super.error});

  @override
  String toString() {
    return error?.toString() ?? 'Unknown error occurred';
  }
}

class ResponseFromServerException extends DioException {
  ResponseFromServerException({required super.requestOptions, required super.error});

  @override
  String toString() {
    return error?.toString() ?? 'Unknown server error';
  }
}

class BadCertificateException extends DioException {
  BadCertificateException({required super.requestOptions, super.error});

  @override
  String toString() {
    return 'Certificate verification failed: ${error?.toString() ?? "Unknown error"}';
  }
}
