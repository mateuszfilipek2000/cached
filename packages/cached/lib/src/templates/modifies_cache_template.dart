import 'package:cached/src/models/cached_method/cached_method.dart';
import 'package:cached/src/models/cached_method/cached_method_with_params.dart';
import 'package:cached/src/models/modifies_cache.dart';
import 'package:cached/src/templates/all_params_template.dart';
import 'package:cached/src/templates/method_with_params_template.dart';
import 'package:cached/src/templates/mixins/clear_method_template_mixin.dart';
import 'package:cached/src/utils/utils.dart';

class ModifiesCacheTemplate extends MethodWithParamsTemplate
    with ClearMethodMixin {
  ModifiesCacheTemplate(
    this.method,
  ) : params = AllParamsTemplate(method.params);

  @override
  final ModifiesCacheMethod method;

  @override
  final AllParamsTemplate params;

  @override
  String get body {
    return '''
  final result = $awaitIfNeeded super.$invocation;

  $generateClearAt

  $_writeNewCacheValues

  return result;
''';
  }

  bool _isCachedReturnTypeCompatible(CachedMethod method) =>
      method.returnType == this.method.returnType;

  String methodParamsKey(CachedMethod method) {
    if (method is CachedMethodWithParams) {
      return getParamKey(method.params);
    }
    return "";
  }

  String get paramsKey => getParamKey(method.params);

  String get _writeNewCacheValues => method.affectedCacheMethods
      .where(_isCachedReturnTypeCompatible)
      .map(
        (method) => '''
${getCacheMapName(method.name)}["${methodParamsKey(method)}}"] = result;
${getTtlMapName(method.name)}["${methodParamsKey(method)}}"] = DateTime.now();
''',
      )
      .join("\n");

  String get generateClearAt => method.affectedCacheMethods
      .map<String?>(
        (cachedMethod) {
          if (paramsKey == methodParamsKey(cachedMethod)) {
            var out =
                '${getCacheMapName(cachedMethod.name)}.remove("${methodParamsKey(cachedMethod)}");';

            if (method.ttlsToClear.contains(cachedMethod.name)) {
              out +=
                  '\n${getTtlMapName(cachedMethod.name)}.remove("${methodParamsKey(cachedMethod)}");';
            }
            return out;
          } else {
            return generateClearMaps();
          }
        },
      )
      .where((element) => element != null)
      .join("\n");
}
