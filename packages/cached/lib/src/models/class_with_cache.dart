import 'package:analyzer/dart/element/element.dart';
import 'package:cached/src/config.dart';
import 'package:cached/src/get_class_methods/get_cache_peek_methods.dart';
import 'package:cached/src/get_class_methods/get_cached_methods.dart';
import 'package:cached/src/get_class_methods/get_clear_all_cache_method.dart';
import 'package:cached/src/get_class_methods/get_clear_cached_methods.dart';
import 'package:cached/src/get_class_methods/get_deletes_cache_methods.dart';
import 'package:cached/src/get_class_methods/get_modifies_cache_methods.dart';
import 'package:cached/src/get_class_methods/get_streamed_cache_method.dart';
import 'package:cached/src/models/cache_peek_method.dart';
import 'package:cached/src/models/cached_method/cached_getter.dart';
import 'package:cached/src/models/cached_method/cached_method_with_params.dart';
import 'package:cached/src/models/clear_all_cached_method.dart';
import 'package:cached/src/models/clear_cached_method.dart';
import 'package:cached/src/models/constructor.dart';
import 'package:cached/src/models/deletes_cache_method.dart';
import 'package:cached/src/models/modifies_cache.dart';
import 'package:cached/src/models/streamed_cache_method.dart';
import 'package:cached/src/utils/asserts.dart';
import 'package:cached_annotation/cached_annotation.dart';
import 'package:collection/collection.dart';
import 'package:source_gen/source_gen.dart';

const _defaultUseStaticCache = false;

class ClassWithCache {
  const ClassWithCache({
    required this.name,
    required this.useStaticCache,
    required this.methods,
    required this.constructor,
    required this.clearMethods,
    required this.streamedCacheMethods,
    required this.cachePeekMethods,
    required this.deletesCacheMethods,
    required this.getters,
    this.clearAllMethod,
    required this.modifiesCacheMethods,
  });

  final bool useStaticCache;
  final String name;
  final Constructor constructor;
  final Iterable<CachedMethodWithParams> methods;
  final Iterable<ClearCachedMethod> clearMethods;
  final Iterable<StreamedCacheMethod> streamedCacheMethods;
  final Iterable<CachePeekMethod> cachePeekMethods;
  final Iterable<DeletesCacheMethod> deletesCacheMethods;
  final ClearAllCachedMethod? clearAllMethod;
  final Iterable<CachedGetter> getters;
  final Iterable<ModifiesCacheMethod> modifiesCacheMethods;

  factory ClassWithCache.fromElement(ClassElement element, Config config) {
    assertAbstract(element);
    assertOneConstFactoryConstructor(element);

    const classAnnotationChecker = TypeChecker.fromRuntime(WithCache);
    final annotation = classAnnotationChecker.firstAnnotationOf(element);

    bool? useStaticCache;

    if (annotation != null) {
      final reader = ConstantReader(annotation);
      final useStaticCacheField = reader.read('useStaticCache');
      if (useStaticCacheField.isBool) {
        useStaticCache = useStaticCacheField.boolValue;
      }
    }

    final constructor = element.constructors
        .map((element) => Constructor.fromElement(element, config))
        .first;

    final methodsAndGettersElements = [
      ...element.methods,
      ...element.accessors.where((element) => element.isGetter)
    ];

    final cachedMethods = GetCachedMethods(config)(methodsAndGettersElements);

    final methodsWithTtls = cachedMethods
        .where((method) => method.ttl != null)
        .map(
          (method) => method.name,
        )
        .toSet();

    final streamedCacheMethods = GetStreamedCacheMethods(
      methodsAndGettersElements,
      config,
    )(element.methods);

    final clearMethods = GetClearCachedMethods(
      config,
      methodsWithTtls,
      streamedCacheMethods,
      cachedMethods,
    )(element.methods);

    final clearAllMethod = GetClearAllCacheMethod(
      config,
      methodsWithTtls,
      streamedCacheMethods,
      cachedMethods,
    )(element.methods)
        .firstOrNull;

    final cachePeekMethods = GetCachePeekMethods(
      methodsAndGettersElements,
      config,
    )(element.methods);

    final deletesCacheMethods = GetDeletesCacheMethods(
      config,
      methodsWithTtls,
      streamedCacheMethods,
      [...cachedMethods],
    )(element.methods);

    final getModifiesCacheMethods = GetModifiesCacheMethods(
      config,
      streamedCacheMethods,
      cachedMethods,
    )(element.methods);

    return ClassWithCache(
      name: element.name,
      useStaticCache:
          useStaticCache ?? config.useStaticCache ?? _defaultUseStaticCache,
      methods: cachedMethods.whereType<CachedMethodWithParams>(),
      clearMethods: clearMethods,
      streamedCacheMethods: streamedCacheMethods,
      constructor: constructor,
      clearAllMethod: clearAllMethod,
      cachePeekMethods: cachePeekMethods,
      deletesCacheMethods: deletesCacheMethods,
      getters: cachedMethods.whereType<CachedGetter>(),
      modifiesCacheMethods: getModifiesCacheMethods,
    );
  }
}
