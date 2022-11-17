import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:cached/src/config.dart';
import 'package:cached/src/models/method_base.dart';
import 'package:cached/src/models/param.dart';
import 'package:cached/src/utils/constant_reader_helpers.dart';
import 'package:cached_annotation/cached_annotation.dart';

import 'package:source_gen/source_gen.dart';

class CachePeekMethod extends MethodBase {
  CachePeekMethod({
    required this.targetMethodName,
    required this.params,
    required String name,
    required String returnType,
    required bool isGenerator,
    required bool isAsync,
    required bool isAbstract,
  }) : super(
          name: name,
          returnType: returnType,
          isGenerator: isGenerator,
          isAsync: isAsync,
          isAbstract: isAbstract,
        );

  final String targetMethodName;
  final Iterable<Param> params;

  factory CachePeekMethod.fromElement(
    ExecutableElement element,
    List<ExecutableElement> classMethods,
    Config config,
    DartObject? annotation,
  ) {
    final methodName = readString(annotation, 'methodName');

    final targetMethod = classMethods.where((m) => m.name == methodName).first;

    final peekCacheMethodType = element.returnType;
    final peekCacheMethodTypeStr =
        peekCacheMethodType.getDisplayString(withNullability: false);

    const ignoreTypeChecker = TypeChecker.any([
      TypeChecker.fromRuntime(Ignore),
      TypeChecker.fromRuntime(IgnoreCache),
    ]);

    final targetMethodParameters = targetMethod.parameters
        .where((p) => !ignoreTypeChecker.hasAnnotationOf(p))
        .toList();

    return CachePeekMethod(
      name: element.name,
      returnType: peekCacheMethodTypeStr,
      params: targetMethodParameters.map((p) => Param.fromElement(p, config)),
      targetMethodName: methodName!,
      isAbstract: element.isAbstract,
      isAsync: element.isAsynchronous,
      isGenerator: element.isGenerator,
    );
  }
}
