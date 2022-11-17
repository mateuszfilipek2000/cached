import 'package:analyzer/dart/element/element.dart';
import 'package:cached/src/config.dart';
import 'package:cached/src/get_class_methods/get_class_method.dart';
import 'package:cached/src/models/streamed_cache_method.dart';
import 'package:cached/src/utils/asserts.dart';
import 'package:cached_annotation/cached_annotation.dart';

class GetStreamedCacheMethods
    extends GetClassMethods<StreamedCache, StreamedCacheMethod> {
  GetStreamedCacheMethods(this.allMethods, this.config);

  final Iterable<ExecutableElement> allMethods;
  final Config config;

  @override
  Iterable<ElementValidator<StreamedCache>> get elementValidators => [
        assertCorrectStreamMethodType,
      ];

  @override
  Iterable<Validator<StreamedCacheMethod>> get validators => [
        (methods) => assertOneCacheStreamPerCachedMethod(
              allMethods,
              methods,
            ),
      ];

  @override
  ElementMapper<StreamedCacheMethod> get mapper =>
      (element) => StreamedCacheMethod.fromElement(
            element,
            allMethods,
            config,
          );
}
