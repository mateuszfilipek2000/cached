import 'package:analyzer/dart/element/element.dart';
import 'package:cached/src/config.dart';
import 'package:cached/src/get_class_methods/get_class_method.dart';
import 'package:cached/src/models/cached_method/cached_getter.dart';
import 'package:cached/src/models/cached_method/cached_method.dart';
import 'package:cached/src/models/cached_method/cached_method_with_params.dart';
import 'package:cached_annotation/cached_annotation.dart';

/// returns all methods annotated with @Cached annotation (getters included)
class GetCachedMethods extends GetClassMethods<Cached, CachedMethod> {
  GetCachedMethods(this.config);

  final Config config;

  @override
  Iterable<ElementValidator<CachedMethod>> get elementValidators => [
        CachedMethod.assertIsValid,
      ];

  @override
  Iterable<Validator<CachedMethod>> get validators => [];

  @override
  ElementMapper<CachedMethod> get mapper => (element) {
        if (element is MethodElement) {
          return CachedMethodWithParams.fromElement(
            element,
            config,
            getAnnotation(element),
          );
        }
        if (element is PropertyAccessorElement && element.isGetter) {
          return CachedGetter.fromElement(
            element,
            config,
            getAnnotation(element),
          );
        }

        throw UnimplementedError();
      };
}
