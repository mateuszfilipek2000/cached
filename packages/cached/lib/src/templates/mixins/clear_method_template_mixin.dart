import 'package:cached/src/models/clear_method_base.dart';
import 'package:cached/src/templates/method_template.dart';
import 'package:cached/src/utils/utils.dart';

mixin ClearMethodMixin on MethodTemplate {
  @override
  ClearMethodBase get method;

  String generateClearMaps() {
    return [
      ...method.methodsToClear.map(
        (methodToClear) => "${getCacheMapName(methodToClear)}.clear();",
      ),
      ...method.ttlsToClear.map(
        (ttlToClearMethodName) =>
            "${getTtlMapName(ttlToClearMethodName)}.clear();",
      ),
      ...method.streamedCacheToClear?.map(
            (streamedMethod) => clearStreamedCache(streamedMethod),
          ) ??
          <String>[]
    ].join("\n");
  }
}
