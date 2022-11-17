import 'package:analyzer/dart/element/element.dart';
import 'package:cached/src/config.dart';
import 'package:cached/src/get_class_methods/get_class_method.dart';
import 'package:cached/src/models/cache_peek_method.dart';
import 'package:cached/src/models/param.dart';
import 'package:cached/src/utils/asserts.dart';
import 'package:cached/src/utils/constant_reader_helpers.dart';
import 'package:cached_annotation/cached_annotation.dart';
import 'package:collection/collection.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

class GetCachePeekMethods extends GetClassMethods<CachePeek, CachePeekMethod> {
  GetCachePeekMethods(this.allMethods, this.config);

  final Iterable<ExecutableElement> allMethods;
  final Config config;

  @override
  Iterable<ElementValidator<CachePeek>> get elementValidators => [
        assertCorrectCachePeekMethodType,
        (element) {
          final methodName = readString(getAnnotation(element), 'methodName');

          final targetMethod =
              allMethods.where((m) => m.name == methodName).firstOrNull;

          if (targetMethod == null) {
            throw InvalidGenerationSourceError(
              '[ERROR] Method "$methodName" do not exists',
              element: element,
            );
          }

          final peekCacheMethodType = element.returnType;
          final peekCacheMethodTypeStr =
              peekCacheMethodType.getDisplayString(withNullability: false);

          const futureTypeChecker = TypeChecker.fromRuntime(Future);
          final targetMethodReturnType =
              targetMethod.returnType.isDartAsyncFuture
                  ? targetMethod.returnType
                      .typeArgumentsOf(futureTypeChecker)
                      ?.single
                  : targetMethod.returnType;

          final targetMethodTypeStr =
              targetMethodReturnType?.getDisplayString(withNullability: false);

          if (peekCacheMethodTypeStr != targetMethodTypeStr) {
            throw InvalidGenerationSourceError(
              '[ERROR] Peek cache method return type needs to be a $targetMethodTypeStr?',
              element: element,
            );
          }

          const cachedAnnotationTypeChecker = TypeChecker.fromRuntime(Cached);

          if (!cachedAnnotationTypeChecker.hasAnnotationOf(targetMethod)) {
            throw InvalidGenerationSourceError(
              '[ERROR] Method "$methodName" do not have @cached annotation',
              element: element,
            );
          }

          const ignoreTypeChecker = TypeChecker.any([
            TypeChecker.fromRuntime(Ignore),
            TypeChecker.fromRuntime(IgnoreCache),
          ]);

          final targetMethodParameters = targetMethod.parameters
              .where((p) => !ignoreTypeChecker.hasAnnotationOf(p))
              .toList();

          if (!ListEquality<ParameterElement>(
            EqualityBy(
              (p) => Param.fromElement(p, config),
            ),
          ).equals(targetMethodParameters, element.parameters)) {
            throw InvalidGenerationSourceError(
              '[ERROR] Method "${targetMethod.name}" should have same parameters as "${element.name}", excluding ones marked with @ignore and @ignoreCache',
              element: element,
            );
          }
        },
      ];

  @override
  Iterable<Validator<CachePeekMethod>> get validators => [
        (cachePeekMethods) => assertOneCachePeekPerCachedMethod(
              allMethods,
              cachePeekMethods,
            )
      ];

  @override
  ElementMapper<CachePeekMethod> get mapper =>
      (element) => CachePeekMethod.fromElement(
            element,
            allMethods.toList(),
            config,
            getAnnotation(element),
          );
}
