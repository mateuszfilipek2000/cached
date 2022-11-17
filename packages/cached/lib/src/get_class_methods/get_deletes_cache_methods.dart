import 'package:cached/src/config.dart';
import 'package:cached/src/get_class_methods/get_class_method.dart';
import 'package:cached/src/models/cached_method/cached_method.dart';
import 'package:cached/src/models/deletes_cache_method.dart';
import 'package:cached/src/models/streamed_cache_method.dart';
import 'package:cached/src/utils/asserts.dart';
import 'package:cached_annotation/cached_annotation.dart';

class GetDeletesCacheMethods
    extends GetClassMethods<DeletesCache, DeletesCacheMethod> {
  const GetDeletesCacheMethods(
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
  Iterable<ElementValidator<DeletesCache>> get elementValidators =>
      [assertCorrectDeletesCacheMethodType];

  @override
  Iterable<Validator<DeletesCacheMethod>> get validators => [
        (Iterable<DeletesCacheMethod> methods) =>
            assertValidateDeletesCacheMethods(
              methods,
              allCachedMethods,
            )
      ];

  @override
  ElementMapper<DeletesCacheMethod> get mapper =>
      (element) => DeletesCacheMethod.fromElement(
            element,
            config,
            allTTLs,
            allStreamedMethods,
            getAnnotation(element),
          );
}
