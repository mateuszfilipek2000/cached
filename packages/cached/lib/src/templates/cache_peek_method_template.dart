import 'package:cached/src/models/cache_peek_method.dart';
import 'package:cached/src/templates/all_params_template.dart';
import 'package:cached/src/templates/method_template.dart';
import 'package:cached/src/templates/mixins/method_params_template.dart';
import 'package:cached/src/utils/utils.dart';

class CachePeekMethodTemplate extends MethodTemplate with MethodParamsTemplate {
  CachePeekMethodTemplate(
    this.method, {
    required this.className,
  }) : paramsTemplate = AllParamsTemplate(method.params);

  @override
  final CachePeekMethod method;
  final String className;
  @override
  final AllParamsTemplate paramsTemplate;

  @override
  String get returnType => "${super.returnType}?";

  @override
  String get body => '''
  final paramsKey = "${getParamKey(method.params)}";

  return ${getCacheMapName(method.targetMethodName)}[paramsKey];
''';
}
