import 'package:cached/src/models/cached_method/cached_method.dart';
import 'package:cached/src/templates/cached_method_base_template.dart';
import 'package:cached/src/templates/mixins/getter_template.dart';

class CachedGetterTemplate extends CachedMethodBaseTemplate
    with GetterTemplate {
  CachedGetterTemplate({
    required this.isCacheStreamed,
    required this.useStaticCache,
    required this.method,
  });

  @override
  final bool isCacheStreamed;

  @override
  final bool useStaticCache;

  @override
  final CachedMethod method;

  @override
  String get paramsKey => '';

  @override
  String get generateAdditionalCacheCondition => "";

  @override
  String get generateOnCatch => "rethrow;";
}
