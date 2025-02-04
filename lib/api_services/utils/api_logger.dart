import 'dart:developer';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dio/dio.dart';

class ApiLogger {
  final int chunkSize = 20;
  final int maxWidth = 90;
  static const int kInitialTab = 1;
  final bool compact = true;
  final String tabStep = '    ';
  final String _timeStampKey = '_pdl_timeStamp_';
  final bool requestHeader = true;
  final bool requestBody = true;
  final bool responseBody = true;
  final bool responseHeader = true;

  logSuccessResponse(Response response) {
    if (requestHeader) _printRequestHeader(response.requestOptions);
    if (requestBody && response.requestOptions.method != 'GET') {
      final dynamic data = response.requestOptions.data;
      if (data != null) {
        if (data is Map) {
          _printMapAsTable(response.requestOptions.data as Map?,
              header: 'Request Body');
        } else if (data is FormData) {
          final formDataMap = <String, dynamic>{}
            ..addEntries(data.fields)
            ..addEntries(data.files);
          _printMapAsTable(formDataMap, header: 'Form data | ${data.boundary}');
        } else {
          _printBlock(data.toString());
        }
      }
    }
    final triggerTime = response.requestOptions.extra[_timeStampKey];

    int diff = 0;
    if (triggerTime is int) {
      diff = DateTime.timestamp().millisecondsSinceEpoch - triggerTime;
    }
    _printResponseHeader(response, diff);
    _printResponse(response);
    _printLine();
  }

  void _printBoxed({String? header, String? text}) {
  log('');
  log('╔╣ $header');
  log('║  $text');
    _printLine('╚');
  }

  void _printResponse(Response response) {
    if (response.data != null) {
      if (response.data is Map) {
        _printPrettyMap(response.data as Map);
      } else if (response.data is Uint8List) {
      log('║${_indent()}[');
        _printUint8List(response.data as Uint8List);
      log('║${_indent()}]');
      } else if (response.data is List) {
      log('║${_indent()}[');
        _printList(response.data as List);
      log('║${_indent()}]');
      } else {
        _printBlock(response.data.toString());
      }
    }
  }

  void _printResponseHeader(Response response, int responseTime) {
    final uri = response.requestOptions.uri;
    final method = response.requestOptions.method;
    _printBoxed(
        header:
            'Response ║ $method ║ Status: ${response.statusCode} ${response.statusMessage}  ║ Time: $responseTime ms',
        text: uri.toString());
  }

  void _printRequestHeader(RequestOptions options) {
    final uri = options.uri;
    final method = options.method;
    _printBoxed(header: 'Request ║ $method ', text: uri.toString());
  }

  void _printLine([String pre = '', String suf = '╝']) =>
    log('$pre${'═' * maxWidth}$suf');

  void _printKV(String? key, Object? v) {
    final pre = '╟ $key: ';
    final msg = v.toString();

    if (pre.length + msg.length > maxWidth) {
    log(pre);
      _printBlock(msg);
    } else {
    log('$pre$msg');
    }
  }

  void _printBlock(String msg) {
    final lines = (msg.length / maxWidth).ceil();
    for (var i = 0; i < lines; ++i) {
    log((i >= 0 ? '║ ' : '') +
          msg.substring(i * maxWidth,
              math.min<int>(i * maxWidth + maxWidth, msg.length)));
    }
  }

  String _indent([int tabCount = kInitialTab]) => tabStep * tabCount;

  void _printPrettyMap(
    Map data, {
    int initialTab = kInitialTab,
    bool isListItem = false,
    bool isLast = false,
  }) {
    var tabs = initialTab;
    final isRoot = tabs == kInitialTab;
    final initialIndent = _indent(tabs);
    tabs++;

    if (isRoot || isListItem)log('║$initialIndent{');

    for (var index = 0; index < data.length; index++) {
      final isLast = index == data.length - 1;
      final key = '"${data.keys.elementAt(index)}"';
      dynamic value = data[data.keys.elementAt(index)];
      if (value is String) {
        value = '"${value.toString().replaceAll(RegExp(r'([\r\n])+'), " ")}"';
      }
      if (value is Map) {
        if (compact && _canFlattenMap(value)) {
        log('║${_indent(tabs)} $key: $value${!isLast ? ',' : ''}');
        } else {
        log('║${_indent(tabs)} $key: {');
          _printPrettyMap(value, initialTab: tabs);
        }
      } else if (value is List) {
        if (compact && _canFlattenList(value)) {
        log('║${_indent(tabs)} $key: ${value.toString()}');
        } else {
        log('║${_indent(tabs)} $key: [');
          _printList(value, tabs: tabs);
        log('║${_indent(tabs)} ]${isLast ? '' : ','}');
        }
      } else {
        final msg = value.toString().replaceAll('\n', '');
        final indent = _indent(tabs);
        final linWidth = maxWidth - indent.length;
        if (msg.length + indent.length > linWidth) {
          final lines = (msg.length / linWidth).ceil();
          for (var i = 0; i < lines; ++i) {
            final multilineKey = i == 0 ? "$key:" : "";
          log(
                '║${_indent(tabs)} $multilineKey ${msg.substring(i * linWidth, math.min<int>(i * linWidth + linWidth, msg.length))}');
          }
        } else {
        log('║${_indent(tabs)} $key: $msg${!isLast ? ',' : ''}');
        }
      }
    }

  log('║$initialIndent}${isListItem && !isLast ? ',' : ''}');
  }

  void _printList(List list, {int tabs = kInitialTab}) {
    for (var i = 0; i < list.length; i++) {
      final element = list[i];
      final isLast = i == list.length - 1;
      if (element is Map) {
        if (compact && _canFlattenMap(element)) {
        log('║${_indent(tabs)}  $element${!isLast ? ',' : ''}');
        } else {
          _printPrettyMap(
            element,
            initialTab: tabs + 1,
            isListItem: true,
            isLast: isLast,
          );
        }
      } else {
      log('║${_indent(tabs + 2)} $element${isLast ? '' : ','}');
      }
    }
  }

  void _printUint8List(Uint8List list, {int tabs = kInitialTab}) {
    var chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
            i, i + chunkSize > list.length ? list.length : i + chunkSize),
      );
    }
    for (var element in chunks) {
    log('║${_indent(tabs)} ${element.join(", ")}');
    }
  }

  bool _canFlattenMap(Map map) {
    return map.values
            .where((dynamic val) => val is Map || val is List)
            .isEmpty &&
        map.toString().length < maxWidth;
  }

  bool _canFlattenList(List list) {
    return list.length < 10 && list.toString().length < maxWidth;
  }

  void _printMapAsTable(Map? map, {String? header}) {
    if (map == null || map.isEmpty) return;
  log('╔ $header ');
    for (final entry in map.entries) {
      _printKV(entry.key.toString(), entry.value);
    }
    _printLine('╚');
  }
}
