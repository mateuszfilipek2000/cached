import 'package:analyzer/dart/element/element.dart';
import 'package:cached/src/config.dart';
import 'package:cached/src/get_class_methods/get_class_method.dart';
import 'package:cached/src/models/cached_method/cached_method.dart';
import 'package:cached/src/models/clear_cached_method.dart';
import 'package:cached/src/models/streamed_cache_method.dart';
import 'package:cached/src/utils/asserts.dart';
import 'package:cached_annotation/cached_annotation.dart';
import 'package:source_gen/source_gen.dart';

class GetClearCachedMethods
    extends GetClassMethods<ClearCached, ClearCachedMethod> {
  const GetClearCachedMethods(
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
  Iterable<ElementValidator<ClearCached>> get elementValidators => [
        (element) {
          if (element is! MethodElement) {
            throw InvalidGenerationSourceError(
              "Invalid target for clear cached annotation",
            );
          }
        },
        (element) => assertCorrectClearMethodType(element as MethodElement),
      ];

  @override
  Iterable<Validator<ClearCachedMethod>> get validators => [
        (clearMethods) =>
            assertValidateClearCachedMethods(clearMethods, allCachedMethods)
      ];

  @override
  ElementMapper<ClearCachedMethod> get mapper =>
      (element) => ClearCachedMethod.fromElement(
            element,
            config,
            allTTLs,
            allStreamedMethods,
            getAnnotation(element),
          );
}
