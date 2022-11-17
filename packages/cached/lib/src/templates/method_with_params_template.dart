import 'package:cached/src/templates/all_params_template.dart';
import 'package:cached/src/templates/method_template.dart';

abstract class MethodWithParamsTemplate extends MethodTemplate {
  const MethodWithParamsTemplate();

  AllParamsTemplate get params;

  @override
  String get definition => "${method.name}(${params.generateParams()})";

  @override
  String get invocation => "${method.name}(${params.generateParamsUsage()})";
}
