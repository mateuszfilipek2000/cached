import 'package:cached/src/config.dart';
import 'package:cached/src/get_class_methods/get_class_method.dart';
import 'package:cached/src/models/cached_method/cached_method.dart';
import 'package:cached/src/models/modifies_cache.dart';
import 'package:cached/src/models/streamed_cache_method.dart';
import 'package:cached_annotation/cached_annotation.dart';

class GetModifiesCacheMethods
    extends GetClassMethods<ModifiesCache, ModifiesCacheMethod> {
  const GetModifiesCacheMethods(
    this.config,
    this.allStreamedMethods,
    this.allCachedMethods,
  );

  final Config config;
  final Iterable<StreamedCacheMethod> allStreamedMethods;
  final Iterable<CachedMethod> allCachedMethods;

  @override
  Iterable<ElementValidator<ModifiesCache>> get elementValidators => [];

  @override
  Iterable<Validator<ModifiesCacheMethod>> get validators => [];

  @override
  ElementMapper<ModifiesCacheMethod> get mapper =>
      (element) => ModifiesCacheMethod.fromElement(
            element,
            getAnnotation(element),
            config,
            allStreamedMethods,
            allCachedMethods,
          );
}
