import 'package:cached/src/models/streamed_cache_method.dart';
import 'package:cached/src/templates/all_params_template.dart';
import 'package:cached/src/templates/method_with_params_template.dart';
import 'package:cached/src/utils/utils.dart';

class StreamedCacheMethodTemplate extends MethodWithParamsTemplate {
  StreamedCacheMethodTemplate(
    this.method, {
    required this.useStaticCache,
    required this.className,
  }) : params = AllParamsTemplate(method.params);

  @override
  final StreamedCacheMethod method;

  final bool useStaticCache;
  final String className;
  @override
  final AllParamsTemplate params;

  String generateStreamMap() {
    return 'static final ${getCacheStreamControllerName(method.targetMethodName)} = ${_streamMapInitializer()};';
  }

  @override
  String get body => '''
  final paramsKey = "${getParamKey(method.params)}";
  final streamController = ${getCacheStreamControllerName(method.targetMethodName)};
  final stream = streamController.stream
        ${_streamFilter()}
        .map((event) => event.value);
        
  ${_lastValueEmit()}
  
  yield* stream;
''';

  String _lastValueEmit() {
    if (!method.emitLastValue) {
      return '';
    }

    return '''
      if(${getCacheMapName(method.targetMethodName)}.containsKey(paramsKey)) {
        final lastValue = ${getCacheMapName(method.targetMethodName)}[paramsKey];
        ${_yieldLastValue()}
      }
    ''';
  }

  String _yieldLastValue() {
    if (method.coreReturnTypeNullable) {
      return 'yield lastValue;';
    }

    return '''
      if(lastValue != null) {
        yield lastValue;
      }
    ''';
  }

  String _streamMapInitializer() =>
      '''StreamController<MapEntry<StreamEventIdentifier<_$className>,${method.coreReturnType}>>.broadcast()''';

  String _streamFilter() => '''
      ${useStaticCache ? "" : ".where((event) => event.key.instance == this)"}
      .where((event) => event.key.paramsKey == null || event.key.paramsKey == paramsKey)
        ''';
}
