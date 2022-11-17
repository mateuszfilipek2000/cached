import 'package:cached/src/models/method_base.dart';
import 'package:cached/src/templates/template.dart';
import 'package:cached/src/utils/utils.dart';

abstract class MethodTemplate extends Template {
  const MethodTemplate();

  MethodBase get method;

  String get body;

  String get definition;

  String get invocation;

  String get asyncModifier =>
      isFuture(method.returnType) || method.isAsync ? 'async' : '';
  String get awaitIfNeeded => isFuture(method.returnType) ? 'await' : '';
  String get syncModifier =>
      method.isGenerator && !method.isAsync ? 'sync' : '';
  String get generatorModifier => method.isGenerator ? '*' : '';
  String get returnKeyword => method.isGenerator ? 'yield*' : 'return';

  String get returnType => method.returnType;

  @override
  String generate() {
    final buffer = StringBuffer();

    buffer.writeln("@override");
    buffer.writeln(
      "$returnType $definition $syncModifier$asyncModifier$generatorModifier {",
    );
    buffer.writeln(body);
    buffer.writeln("}");

    return buffer.toString();
  }
}
