import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:cached/src/config.dart';
import 'package:cached/src/models/cached_function.dart';
import 'package:cached/src/models/param.dart';
import 'package:cached/src/utils/asserts.dart';
import 'package:cached_annotation/cached_annotation.dart';
import 'package:source_gen/source_gen.dart';

const _defaultSyncWriteValue = false;

class CachedMethod extends CachedFunction {
  CachedMethod({
    required this.params,
    required String name,
    required bool syncWrite,
    required String returnType,
    required bool isGenerator,
    required bool isAsync,
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
        );

  final Iterable<Param> params;

  factory CachedMethod.fromElement(MethodElement element, Config config) {
    CachedFunction.assertIsValid(element);

    final annotation = getAnnotation(element);

    bool? syncWrite;
    int? limit;
    int? ttl;

    if (annotation != null) {
      final reader = ConstantReader(annotation);
      final syncWriteField = reader.read('syncWrite');
      final limitField = reader.read('limit');
      final ttlField = reader.read('ttl');

      if (syncWriteField.isBool) {
        syncWrite = syncWriteField.boolValue;
      }
      if (limitField.isInt) {
        limit = limitField.intValue;
      }
      if (ttlField.isInt) {
        ttl = ttlField.intValue;
      }
    }

    final method = CachedMethod(
      name: element.name,
      syncWrite: syncWrite ?? config.syncWrite ?? _defaultSyncWriteValue,
      limit: limit ?? config.limit,
      ttl: ttl ?? config.ttl,
      returnType: element.returnType.getDisplayString(withNullability: true),
      isAsync: element.isAsynchronous,
      isGenerator: element.isGenerator,
      params: element.parameters.map((e) => Param.fromElement(e, config)),
    );
    assertOneIgnoreCacheParam(method);

    return method;
  }

  static DartObject? getAnnotation(MethodElement element) {
    const methodAnnotationChecker = TypeChecker.fromRuntime(Cached);
    return methodAnnotationChecker.firstAnnotationOf(element);
  }
}
