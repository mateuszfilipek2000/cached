import 'package:cached/src/templates/method_template.dart';

mixin GetterTemplate on MethodTemplate {
  @override
  String get definition => "get ${method.name}";

  @override
  String get invocation => method.name;
}
