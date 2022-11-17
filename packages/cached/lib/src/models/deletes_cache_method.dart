import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:cached/src/config.dart';
import 'package:cached/src/models/clear_method_base.dart';
import 'package:cached/src/models/param.dart';
import 'package:cached/src/models/streamed_cache_method.dart';
import 'package:cached/src/utils/constant_reader_helpers.dart';

class DeletesCacheMethod extends ClearMethodBase {
  DeletesCacheMethod({
    required this.params,
    required String name,
    required String returnType,
    required bool isGenerator,
    required bool isAsync,
    required bool isAbstract,
    required Iterable<String> methodsToClear,
    required Iterable<String> ttlsToClear,
    required Iterable<StreamedCacheMethod>? streamedCacheToClear,
  }) : super(
          name: name,
          returnType: returnType,
          isGenerator: isGenerator,
          isAsync: isAsync,
          isAbstract: isAbstract,
          methodsToClear: methodsToClear,
          ttlsToClear: ttlsToClear,
          streamedCacheToClear: streamedCacheToClear,
        );

  final Iterable<Param> params;

  factory DeletesCacheMethod.fromElement(
    ExecutableElement element,
    Config config,
    Iterable<String> allTTLs,
    Iterable<StreamedCacheMethod> allStreamedMethods,
    DartObject? annotation,
  ) {
    final methodNames = readStringList(annotation, 'methodNames');

    return DeletesCacheMethod(
      name: element.name,
      methodsToClear: methodNames ?? [],
      returnType: element.returnType.getDisplayString(withNullability: true),
      isAsync: element.isAsynchronous,
      isGenerator: element.isGenerator,
      params: element.parameters.map((e) => Param.fromElement(e, config)),
      ttlsToClear: allTTLs.where(
        (methodWithTTL) => methodNames?.contains(methodWithTTL) ?? false,
      ),
      streamedCacheToClear: allStreamedMethods.where(
        (streamedCacheMethod) =>
            methodNames?.contains(streamedCacheMethod.targetMethodName) ??
            false,
      ),
      isAbstract: element.isAbstract,
    );
  }
}
