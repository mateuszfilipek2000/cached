import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:cached/src/config.dart';
import 'package:cached/src/models/cached_method/cached_method.dart';
import 'package:cached/src/models/clear_method_base.dart';
import 'package:cached/src/models/param.dart';
import 'package:cached/src/models/streamed_cache_method.dart';
import 'package:cached/src/utils/constant_reader_helpers.dart';

class ModifiesCacheMethod extends ClearMethodBase {
  ModifiesCacheMethod({
    required this.params,
    required this.affectedCacheMethods,
    required String name,
    required String returnType,
    required bool isGenerator,
    required bool isAsync,
    required bool isAbstract,
    required Iterable<StreamedCacheMethod> streamedCacheToClear,
  }) : super(
          name: name,
          returnType: returnType,
          isGenerator: isGenerator,
          isAsync: isAsync,
          isAbstract: isAbstract,
          methodsToClear: affectedCacheMethods.map((e) => e.name),
          ttlsToClear: affectedCacheMethods
              .where((element) => element.ttl != null)
              .map((e) => e.name),
          streamedCacheToClear: streamedCacheToClear,
        );

  final Iterable<Param> params;
  final Iterable<CachedMethod> affectedCacheMethods;

  factory ModifiesCacheMethod.fromElement(
    ExecutableElement element,
    DartObject? annotation,
    Config config,
    Iterable<StreamedCacheMethod> allStreamedMethods,
    Iterable<CachedMethod> allCachedMethods,
  ) {
    final methodNames = readStringList(annotation, 'methodNames');

    final affectedCacheMethods = allCachedMethods
        .where((element) => methodNames?.contains(element.name) ?? false);

    print(allStreamedMethods
        .where(
          (streamedCacheMethod) =>
              methodNames?.contains(streamedCacheMethod.targetMethodName) ??
              false,
        )
        .map((e) => e.name));

    final method = ModifiesCacheMethod(
      name: element.name,
      returnType: element.returnType.getDisplayString(withNullability: true),
      isAsync: element.isAsynchronous,
      isGenerator: element.isGenerator,
      params: element.parameters.map((e) => Param.fromElement(e, config)),
      isAbstract: element.isAbstract,
      affectedCacheMethods: affectedCacheMethods,
      streamedCacheToClear: allStreamedMethods.where(
        (streamedCacheMethod) =>
            methodNames?.contains(streamedCacheMethod.targetMethodName) ??
            false,
      ),
    );

    return method;
  }

  @override
  String toString() {
    return <String>[
      "{",
      "\tname: $name",
      "\tmethods: ${methodsToClear.join(',')}",
      "\tttls: ${ttlsToClear.join(',')}",
      "}",
    ].join("\n");
  }
}
