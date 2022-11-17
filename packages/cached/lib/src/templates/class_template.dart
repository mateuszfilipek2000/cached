import 'package:cached/src/models/cached_method/cached_method.dart';
import 'package:cached/src/models/class_with_cache.dart';
import 'package:cached/src/templates/all_params_template.dart';
import 'package:cached/src/templates/cache_peek_method_template.dart';
import 'package:cached/src/templates/cached_getter_template.dart';
import 'package:cached/src/templates/cached_map_template.dart';
import 'package:cached/src/templates/cached_method_template.dart';
import 'package:cached/src/templates/cached_method_ttl_template.dart';
import 'package:cached/src/templates/cached_sync_map_template.dart';
import 'package:cached/src/templates/clear_all_cached_method_template.dart';
import 'package:cached/src/templates/clear_cached_method_template.dart';
import 'package:cached/src/templates/deletes_cache_method_template.dart';
import 'package:cached/src/templates/method_template.dart';
import 'package:cached/src/templates/modifies_cache_template.dart';
import 'package:cached/src/templates/streamed_method_template.dart';
import 'package:cached/src/templates/template.dart';

class ClassTemplate implements Template {
  ClassTemplate({
    required this.name,
    required this.paramsTemplate,
    required this.methodTemplates,
  });

  factory ClassTemplate.fromClassWithCache(
    ClassWithCache classWithCache,
  ) {
    final classMethods = classWithCache.methods;

    final methodTemplates = classMethods.map(
      (e) => CachedMethodTemplate(
        method: e,
        useStaticCache: classWithCache.useStaticCache,
        isCacheStreamed: classWithCache.streamedCacheMethods
            .any((s) => s.targetMethodName == e.name),
      ),
    );

    final getterTemplates = classWithCache.getters.map(
      (e) => CachedGetterTemplate(
        method: e,
        useStaticCache: classWithCache.useStaticCache,
        isCacheStreamed: classWithCache.streamedCacheMethods
            .any((s) => s.targetMethodName == e.name),
      ),
    );

    final streamedCacheMethodTemplates =
        classWithCache.streamedCacheMethods.map(
      (e) => StreamedCacheMethodTemplate(
        e,
        useStaticCache: classWithCache.useStaticCache,
        className: classWithCache.name,
      ),
    );

    final clearMethodTemplates = classWithCache.clearMethods.map(
      (e) => ClearCachedMethodTemplate(
        method: e,
      ),
    );

    final clearAllMethodTemplate = classWithCache.clearAllMethod != null
        ? ClearAllCachedMethodTemplate(
            method: classWithCache.clearAllMethod!,
          )
        : null;

    final cachePeekMethodTemplates = classWithCache.cachePeekMethods.map(
      (e) => CachePeekMethodTemplate(
        e,
        className: classWithCache.name,
      ),
    );

    final deletesCacheMethodTemplates = classWithCache.deletesCacheMethods.map(
      (method) => DeletesCacheMethodTemplate(
        method,
      ),
    );

    final modifiesCacheTemplates = classWithCache.modifiesCacheMethods.map(
      (e) => ModifiesCacheTemplate(e),
    );

    return ClassTemplate(
      name: classWithCache.name,
      paramsTemplate: AllParamsTemplate(classWithCache.constructor.params),
      methodTemplates: [
        ...methodTemplates,
        ...getterTemplates,
        ...streamedCacheMethodTemplates,
        ...clearMethodTemplates,
        if (clearAllMethodTemplate != null) clearAllMethodTemplate,
        ...cachePeekMethodTemplates,
        ...deletesCacheMethodTemplates,
        ...modifiesCacheTemplates,
      ],
    );
  }

  final String name;

  final AllParamsTemplate paramsTemplate;

  final Iterable<MethodTemplate> methodTemplates;

  Iterable<CachedMethod> get cachedMethods =>
      methodTemplates.whereType<CachedMethod>();

  @override
  String generate() {
    final buffer = StringBuffer();

    buffer.writeln("class _$name with $name implements _\$$name {");

    buffer.writeln("_$name(${paramsTemplate.generateThisParams()});\n");

    buffer.writeln(
      paramsTemplate.generateFields(addOverrideAnnotation: true),
    );

    methodTemplates
        .whereType<CachedSyncMapTemplate>()
        .map(
          (e) => e.generateSyncMap(),
        )
        .forEach(buffer.writeln);

    buffer.writeln();

    methodTemplates
        .whereType<CachedMapTemplate>()
        .map(
          (e) => e.generateCacheMap(),
        )
        .forEach(buffer.writeln);

    buffer.writeln();

    methodTemplates
        .whereType<CachedMethodTTLTemplate>()
        .map(
          (e) => e.generateTtlMap(),
        )
        .forEach(buffer.writeln);

    buffer.writeln();

    methodTemplates
        .whereType<StreamedCacheMethodTemplate>()
        .map(
          (e) => e.generateStreamMap(),
        )
        .forEach(buffer.writeln);

    buffer.writeln();

    methodTemplates.map((e) => e.generate()).forEach(buffer.writeln);

    buffer.writeln("}");

    return buffer.toString();
  }
}
