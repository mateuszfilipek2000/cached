import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:cached/src/models/method_base.dart';
import 'package:cached/src/utils/utils.dart';
import 'package:source_gen/source_gen.dart';

typedef ElementValidator<T> = void Function(ExecutableElement element);
typedef ElementMapper<T> = T Function(ExecutableElement element);
typedef Validator<T> = void Function(Iterable<T> methods);

abstract class GetClassMethods<T, M extends MethodBase> {
  const GetClassMethods();

  Iterable<ElementValidator<T>> get elementValidators;

  Iterable<Validator<M>> get validators;

  ElementMapper<M> get mapper;

  Type get annotation => T;

  Iterable<M> call(
    Iterable<ExecutableElement> elements,
  ) {
    final mapped = elements
        .where(
      (element) => getAnnotation(element) != null,
    )
        .inspect(
      (element) {
        for (final validator in elementValidators) {
          validator(element);
        }
      },
    ).map(mapper);

    for (final validator in validators) {
      validator(mapped);
    }

    return mapped;
  }

  DartObject? getAnnotation(ExecutableElement element) {
    final methodAnnotationChecker = TypeChecker.fromRuntime(annotation);
    return methodAnnotationChecker.firstAnnotationOf(element);
  }
}
