import 'package:cached/src/models/cached_method/cached_method_with_params.dart';
import 'package:cached/src/models/param.dart';
import 'package:cached/src/templates/all_params_template.dart';
import 'package:cached/src/templates/cached_method_base_template.dart';
import 'package:cached/src/templates/mixins/method_params_template.dart';
import 'package:cached/src/utils/utils.dart';
import 'package:collection/collection.dart';

class CachedMethodTemplate extends CachedMethodBaseTemplate
    with MethodParamsTemplate {
  CachedMethodTemplate({
    required this.isCacheStreamed,
    required this.useStaticCache,
    required this.method,
  }) : paramsTemplate = AllParamsTemplate(method.params);

  @override
  final bool isCacheStreamed;

  @override
  final bool useStaticCache;

  @override
  final CachedMethodWithParams method;

  @override
  final AllParamsTemplate paramsTemplate;

  Param? get ignoreCacheParam => method.params
      .firstWhereOrNull((element) => element.ignoreCacheAnnotation != null);

  @override
  String get paramsKey => getParamKey(method.params);

  @override
  String get generateAdditionalCacheCondition =>
      ignoreCacheParam != null ? '|| ${ignoreCacheParam!.name}' : '';

  @override
  String get generateOnCatch {
    final useCacheOnError =
        ignoreCacheParam?.ignoreCacheAnnotation?.useCacheOnError ?? false;
    return '${useCacheOnError ? "if (cachedValue != null) { return cachedValue;\n }" : ""}rethrow;';
  }
}
