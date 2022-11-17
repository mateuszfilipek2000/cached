import 'package:cached/src/models/clear_all_cached_method.dart';
import 'package:cached/src/templates/all_params_template.dart';
import 'package:cached/src/templates/method_template.dart';
import 'package:cached/src/templates/mixins/clear_method_template_mixin.dart';
import 'package:cached/src/templates/mixins/method_params_template.dart';
import 'package:cached/src/utils/utils.dart';

class ClearAllCachedMethodTemplate extends MethodTemplate
    with ClearMethodMixin, MethodParamsTemplate {
  ClearAllCachedMethodTemplate({
    required this.method,
  }) : paramsTemplate = AllParamsTemplate(method.params);

  @override
  final ClearAllCachedMethod method;
  @override
  final AllParamsTemplate paramsTemplate;

  @override
  String get body {
    if (method.isAbstract) return _generateAbstractMethod();

    if (isFutureBool(method.returnType) || isBool(method.returnType)) {
      return _generateBoolMethod();
    }

    return '''
    $awaitIfNeeded super.$invocation;

    ${generateClearMaps()}
    ''';
  }

  String _generateBoolMethod() {
    return '''
    final ${syncReturnType(method.returnType)} toReturn;

    final result = super.$invocation;
    toReturn = $awaitIfNeeded result;

    if(toReturn) {
      ${generateClearMaps()}
    }

    return toReturn;
    ''';
  }

  String _generateAbstractMethod() {
    return generateClearMaps();
  }

  // String _generateAbstractMethod() {
  //   return '''
  //   @override
  //     ${method.returnType} ${method.name}() $asyncModifier {
  //     ${_generateCacheClearMethods()}
  //   }
  //   ''';
  // }

//   String _generateClearMaps(
//     String baseName,
//     StreamedCacheMethod? streamedCacheMethod,
//   ) {
//     return '''
// ${getCacheMapName(baseName)}.clear();
// ${method.ttlsToClear.contains(baseName) ? "${getTtlMapName(baseName)}.clear();" : ""}
// ${clearStreamedCache(streamedCacheMethod)}
// ''';
//   }
}
