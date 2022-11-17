import 'package:cached/src/templates/all_params_template.dart';
import 'package:cached/src/templates/method_template.dart';

mixin MethodParamsTemplate on MethodTemplate {
  AllParamsTemplate get paramsTemplate;

  @override
  String get definition => "${method.name}(${paramsTemplate.generateParams()})";

  @override
  String get invocation =>
      "${method.name}(${paramsTemplate.generateParamsUsage()})";
}
