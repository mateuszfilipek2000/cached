import 'package:cached/src/models/deletes_cache_method.dart';
import 'package:cached/src/templates/all_params_template.dart';
import 'package:cached/src/templates/method_with_params_template.dart';
import 'package:cached/src/templates/mixins/clear_method_template_mixin.dart';

class DeletesCacheMethodTemplate extends MethodWithParamsTemplate
    with ClearMethodMixin {
  DeletesCacheMethodTemplate(
    this.method,
  ) : params = AllParamsTemplate(method.params);

  @override
  final DeletesCacheMethod method;

  @override
  final AllParamsTemplate params;

  @override
  String get body => '''
  final result = $awaitIfNeeded super.$invocation;

  ${generateClearMaps()}

  return result;
''';
}
