import 'package:cached/src/models/cached_method/cached_method.dart';
import 'package:cached/src/templates/cached_map_template.dart';
import 'package:cached/src/templates/cached_method_ttl_template.dart';
import 'package:cached/src/templates/cached_sync_map_template.dart';
import 'package:cached/src/templates/method_template.dart';
import 'package:cached/src/templates/stream_cache_template.dart';
import 'package:cached/src/utils/utils.dart';

abstract class CachedMethodBaseTemplate extends MethodTemplate
    implements
        CachedMethodTTLTemplate,
        CachedSyncMapTemplate,
        StreamCacheTemplate,
        CachedMapTemplate {
  const CachedMethodBaseTemplate();

  @override
  CachedMethod get method;

  String get generateAdditionalCacheCondition;
  String get generateOnCatch;

  bool get isCacheStreamed;
  bool get useStaticCache;
  String get paramsKey;

  String get ttlMapName => getTtlMapName(method.name);
  String get getStaticModifier => useStaticCache ? 'static' : '';

  String get cacheMapName => getCacheMapName(method.name);
  String get syncMapName => '_${method.name}Sync';

  @override
  String get body {
    return '''
  ${generateRemoveTtlLogic()}
  final cachedValue = $cacheMapName["$paramsKey"];
  if (cachedValue == null $generateAdditionalCacheCondition) {
    $syncLogic

    final ${syncReturnType(method.returnType)} toReturn;
    try {
      final result = super.$invocation;
      ${method.syncWrite && isFuture(method.returnType) ? "$syncMapName['$paramsKey'] = result;" : ""}
      toReturn = $awaitIfNeeded result;
    } catch(_) {
      $generateOnCatch
    } finally {
      ${method.syncWrite && isFuture(method.returnType) ? "$syncMapName.remove('$paramsKey');" : ""}
    }

    $cacheMapName["$paramsKey"] = toReturn;

    ${generateStreamCall()}

    ${generateLimitLogic()}
    ${generateAddTtlLogic()}
    $returnKeyword toReturn;
  } else {
    $returnKeyword cachedValue;
  }
''';
  }

  String get syncLogic => (!method.syncWrite || !isFuture(method.returnType))
      ? ''
      : '''
final cachedFuture = $syncMapName["$paramsKey"];

if (cachedFuture != null) {
  return cachedFuture;
}
''';

  String generateLimitLogic() {
    if (method.limit == null) return '';

    return '''
if ($cacheMapName.length > ${method.limit}) {
  $cacheMapName.remove($cacheMapName.entries.last.key);
}
''';
  }

  @override
  String generateTtlMap() {
    if (method.ttl == null) {
      return '';
    }

    return '$getStaticModifier final $ttlMapName = <String, DateTime>{};';
  }

  String generateAddTtlLogic() {
    if (method.ttl == null) return '';

    return '''
$ttlMapName["$paramsKey"] = DateTime.now().add(const Duration(seconds: ${method.ttl}));
''';
  }

  String generateRemoveTtlLogic() {
    if (method.ttl == null) return '';

    return '''
final now = DateTime.now();
final currentTtl = $ttlMapName["$paramsKey"];

if (currentTtl != null && currentTtl.isBefore(now)) {
  $ttlMapName.remove("$paramsKey");
  $cacheMapName.remove("$paramsKey");
}
''';
  }

  @override
  String generateSyncMap() {
    if (!method.syncWrite) {
      return '';
    }

    return '${_getStaticModifier()} final $syncMapName = <String, Future<${syncReturnType(method.returnType)}>>{};';
  }

  @override
  String generateCacheMap() {
    return '${_getStaticModifier()} final $cacheMapName = <String, ${syncReturnType(method.returnType)}>{};';
  }

  String _getStaticModifier() {
    return useStaticCache ? 'static' : '';
  }

  @override
  String generateStreamCall() {
    if (!isCacheStreamed) {
      return '';
    }
    return '''
          ${getCacheStreamControllerName(method.name)}.sink.add(MapEntry(StreamEventIdentifier(
              ${useStaticCache ? '' : 'instance: this,'}
              paramsKey: "$paramsKey",
            ),
            toReturn,
          ));
          ''';
  }
}
