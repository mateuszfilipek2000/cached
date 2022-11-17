import 'package:analyzer/dart/element/element.dart';
import 'package:cached/src/config.dart';
import 'package:cached/src/models/clear_method_base.dart';
import 'package:cached/src/models/param.dart';
import 'package:cached/src/models/streamed_cache_method.dart';

class ClearAllCachedMethod extends ClearMethodBase {
  ClearAllCachedMethod({
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

  factory ClearAllCachedMethod.fromElement(
    ExecutableElement element,
    Config config,
    Iterable<String> allCachedMethods,
    Iterable<String> allTTLs,
    Iterable<StreamedCacheMethod> allStreamedMethods,
  ) {
    return ClearAllCachedMethod(
      name: element.name,
      returnType: element.returnType.getDisplayString(withNullability: true),
      isAsync: element.isAsynchronous,
      isAbstract: element.isAbstract,
      params: element.parameters.map((e) => Param.fromElement(e, config)),
      ttlsToClear: allTTLs.where(
        (methodWithTTL) => allCachedMethods.contains(methodWithTTL),
      ),
      isGenerator: element.isGenerator,
      methodsToClear: allCachedMethods,
      streamedCacheToClear: allStreamedMethods.where(
        (streamedCacheMethod) =>
            allCachedMethods.contains(streamedCacheMethod.targetMethodName),
      ),
    );
  }
}
