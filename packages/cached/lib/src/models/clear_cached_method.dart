import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:cached/src/config.dart';
import 'package:cached/src/extensions.dart';
import 'package:cached/src/models/clear_method_base.dart';
import 'package:cached/src/models/param.dart';
import 'package:cached/src/models/streamed_cache_method.dart';
import 'package:cached/src/utils/constant_reader_helpers.dart';
import 'package:source_gen/source_gen.dart';

const String _clearPrefix = 'clear';

class ClearCachedMethod extends ClearMethodBase {
  ClearCachedMethod({
    required this.params,
    required String name,
    required String returnType,
    required bool isGenerator,
    required bool isAsync,
    required bool isAbstract,
    required Iterable<String> methodsToClear,
    required Iterable<String> ttlsToClear,
    required Iterable<StreamedCacheMethod>? streamedCacheToClear,
  }) : super(
          name: name,
          returnType: returnType,
          isGenerator: isGenerator,
          isAsync: isAsync,
          isAbstract: isAbstract,
          methodsToClear: methodsToClear,
          ttlsToClear: ttlsToClear,
          streamedCacheToClear: streamedCacheToClear,
        );

  final Iterable<Param> params;

  factory ClearCachedMethod.fromElement(
    ExecutableElement element,
    Config config,
    Iterable<String> allTTLs,
    Iterable<StreamedCacheMethod> allStreamedMethods,
    DartObject? annotation,
  ) {
    var methodName = readString(annotation, 'methodName');

    if (methodName == null || methodName.isEmpty) {
      if (!element.name.contains(_clearPrefix)) {
        throw InvalidGenerationSourceError(
          '''
[ERROR] Name of method for which cache should be cleared is not provider.
Provide it trougth annotation parameter (`@ClearCached('methodName')`)
or trougth clear function name e.g. `void ${_clearPrefix}MethodName();`
''',
          element: element,
        );
      }

      methodName =
          element.name.replaceAll(_clearPrefix, '').startsWithLowerCase();
    }

    return ClearCachedMethod(
      name: element.name,
      methodsToClear: [methodName],
      returnType: element.returnType.getDisplayString(withNullability: true),
      isAsync: element.isAsynchronous,
      isGenerator: element.isGenerator,
      isAbstract: element.isAbstract,
      params: element.parameters.map((e) => Param.fromElement(e, config)),
      ttlsToClear: allTTLs.where(
        (methodWithTTL) => methodWithTTL == methodName,
      ),
      streamedCacheToClear: allStreamedMethods.where(
        (streamedCacheMethod) => streamedCacheMethod.name == methodName,
      ),
    );
  }
}
