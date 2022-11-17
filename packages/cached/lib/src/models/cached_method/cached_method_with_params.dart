import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:cached/src/config.dart';
import 'package:cached/src/models/cached_method/cached_method.dart';
import 'package:cached/src/models/param.dart';
import 'package:cached/src/utils/asserts.dart';
import 'package:cached/src/utils/constant_reader_helpers.dart';

const _defaultSyncWriteValue = false;

class CachedMethodWithParams extends CachedMethod {
  CachedMethodWithParams({
    required this.params,
    required String name,
    required bool syncWrite,
    required String returnType,
    required bool isGenerator,
    required bool isAsync,
    required bool isAbstract,
    int? limit,
    int? ttl,
  }) : super(
          name: name,
          syncWrite: syncWrite,
          returnType: returnType,
          isGenerator: isGenerator,
          isAsync: isAsync,
          limit: limit,
          ttl: ttl,
          isAbstract: isAbstract,
        );

  final Iterable<Param> params;

  factory CachedMethodWithParams.fromElement(
    MethodElement element,
    Config config,
    DartObject? annotation,
  ) {
    final props = readCacheAnnotationProperties(annotation);

    final method = CachedMethodWithParams(
      name: element.name,
      syncWrite: props?.syncWrite ?? config.syncWrite ?? _defaultSyncWriteValue,
      limit: props?.limit ?? config.limit,
      ttl: props?.ttl ?? config.ttl,
      returnType: element.returnType.getDisplayString(withNullability: true),
      isAsync: element.isAsynchronous,
      isGenerator: element.isGenerator,
      params: element.parameters.map((e) => Param.fromElement(e, config)),
      isAbstract: element.isAbstract,
    );

    assertOneIgnoreCacheParam(method);

    return method;
  }
}
