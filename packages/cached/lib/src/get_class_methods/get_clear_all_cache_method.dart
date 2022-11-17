import 'package:analyzer/dart/element/element.dart';
import 'package:cached/src/config.dart';
import 'package:cached/src/get_class_methods/get_class_method.dart';
import 'package:cached/src/models/cached_method/cached_method.dart';
import 'package:cached/src/models/clear_all_cached_method.dart';
import 'package:cached/src/models/streamed_cache_method.dart';
import 'package:cached/src/utils/asserts.dart';
import 'package:cached_annotation/cached_annotation.dart';
import 'package:source_gen/source_gen.dart';

class GetClearAllCacheMethod
    extends GetClassMethods<ClearAllCached, ClearAllCachedMethod> {
  const GetClearAllCacheMethod(
    this.config,
    this.allTTLs,
    this.allStreamedMethods,
    this.allCachedMethods,
  );

  final Config config;
  final Iterable<String> allTTLs;
  final Iterable<StreamedCacheMethod> allStreamedMethods;
  final Iterable<CachedMethod> allCachedMethods;

  @override
  Iterable<Validator<ClearAllCachedMethod>> get validators => [
        assertOneClearAllCachedAnnotation,
      ];

  @override
  Iterable<ElementValidator<ClearAllCached>> get elementValidators => [
        (element) {
          if (element is! MethodElement) {
            throw InvalidGenerationSourceError(
              "Invalid target for clear all cached annotation",
            );
          }
        },
        (element) => assertCorrectClearMethodType(element as MethodElement),
      ];

  @override
  ElementMapper<ClearAllCachedMethod> get mapper =>
      (element) => ClearAllCachedMethod.fromElement(
            element,
            config,
            allCachedMethods.map((method) => method.name),
            allTTLs,
            allStreamedMethods,
          );
}
