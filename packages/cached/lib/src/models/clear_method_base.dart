import 'package:cached/src/models/method_base.dart';
import 'package:cached/src/models/streamed_cache_method.dart';

abstract class ClearMethodBase extends MethodBase {
  ClearMethodBase({
    required this.methodsToClear,
    required this.ttlsToClear,
    required this.streamedCacheToClear,
    required String name,
    required bool isAbstract,
    required bool isAsync,
    required bool isGenerator,
    required String returnType,
  }) : super(
          name: name,
          isAbstract: isAbstract,
          isAsync: isAsync,
          isGenerator: isGenerator,
          returnType: returnType,
        );

  final Iterable<String> methodsToClear;
  final Iterable<String> ttlsToClear;
  final Iterable<StreamedCacheMethod>? streamedCacheToClear;
}
