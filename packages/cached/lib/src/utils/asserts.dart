import 'package:analyzer/dart/element/element.dart';
import 'package:cached/src/models/cache_peek_method.dart';
import 'package:cached/src/models/cached_method/cached_method.dart';
import 'package:cached/src/models/cached_method/cached_method_with_params.dart';
import 'package:cached/src/models/clear_all_cached_method.dart';
import 'package:cached/src/models/clear_cached_method.dart';
import 'package:cached/src/models/deletes_cache_method.dart';
import 'package:cached/src/models/streamed_cache_method.dart';
import 'package:cached/src/utils/utils.dart';
import 'package:source_gen/source_gen.dart';

void assertMethodNotVoid(ExecutableElement element) {
  if (element.returnType.isVoid ||
      element.returnType.getDisplayString(withNullability: false) ==
          'Future<void>') {
    throw InvalidGenerationSourceError(
      '[ERROR] Method ${element.name} returns void or Future<void> which is not allowed',
      element: element,
    );
  }
}

void assertMethodIsNotAbstract(ExecutableElement element) {
  if (element.isAbstract) {
    throw InvalidGenerationSourceError(
      '[ERROR] Cached method ${element.name} is abstract which is not allowed',
      element: element,
    );
  }
}

void assertAbstract(ClassElement element) {
  if (!element.isAbstract) {
    throw InvalidGenerationSourceError(
      '[ERROR] Class ${element.name} need to be abstract',
      element: element,
    );
  }
}

void assertOneIgnoreCacheParam(CachedMethodWithParams method) {
  final ignoraCacheParams =
      method.params.where((element) => element.ignoreCacheAnnotation != null);

  if (ignoraCacheParams.length > 1) {
    throw InvalidGenerationSourceError(
      '[ERROR] Multiple IgnoreCache annotations in ${method.name} method',
    );
  }
}

void assertOneConstFactoryConstructor(ClassElement element) {
  final constructorElements = element.constructors;

  if (constructorElements.length != 1) {
    throw InvalidGenerationSourceError(
      '[ERROR] To many constructors in ${element.name} class. Class can have only one constructor',
      element: element,
    );
  }

  final constructor = constructorElements.first;

  if (!constructor.isFactory) {
    throw InvalidGenerationSourceError(
      '[ERROR] Class ${element.name} need to have one factory constructor',
      element: element,
    );
  }
}

void assertOneClearAllCachedAnnotation(
  Iterable<ClearAllCachedMethod> clearAllMethod,
) {
  if (clearAllMethod.length > 1) {
    throw InvalidGenerationSourceError(
      '[ERROR] Too many `clearAllCached` annotation, only one can be',
    );
  }
}

void assertValidateClearCachedMethods(
  Iterable<ClearCachedMethod> clearMethods,
  Iterable<CachedMethod> methods,
) {
  for (final ClearCachedMethod clearMethod in clearMethods) {
    final hasPair = [
      methods.where(
        (method) => clearMethod.methodsToClear.any(
          (methodToClear) => methodToClear == method.name,
        ),
      ),
    ].expand((element) => element).isNotEmpty;

    if (!hasPair) {
      throw InvalidGenerationSourceError(
        '[ERROR] No cache target for `${clearMethod.name}` method',
      );
    }

    if (clearMethods
            .where(
              (method) => method.methodsToClear.any(
                (e) => clearMethod.methodsToClear.contains(e),
              ),
            )
            .length >
        1) {
      throw InvalidGenerationSourceError(
        '[ERROR] There are multiple targets with ClearCached annotation with the same argument',
      );
    }
  }
}

void assertCorrectClearMethodType(MethodElement element) {
  final returnType = element.returnType.getDisplayString(withNullability: true);

  if (element.isAbstract) {
    if (element.isAsynchronous) {
      throw InvalidGenerationSourceError(
        '[ERROR] `${element.name}` must be not async method',
        element: element,
      );
    }

    if (!(isAsyncVoid(returnType) || isVoid(returnType))) {
      throw InvalidGenerationSourceError(
        '[ERROR] `${element.name}` must be a void or Future<void> method',
        element: element,
      );
    }

    if (element.parameters.isNotEmpty) {
      throw InvalidGenerationSourceError(
        '[ERROR] `${element.name}` method cant have arguments',
        element: element,
      );
    }
  } else {
    if (!isVoid(returnType) &&
        !isBool(returnType) &&
        !isAsyncVoid(returnType) &&
        !isFutureBool(returnType)) {
      throw InvalidGenerationSourceError(
        '[ERROR] `${element.name}` return type must be a void, Future<void>, bool, Future<bool>',
        element: element,
      );
    }
  }
}

void assertOneCacheStreamPerCachedMethod(
  Iterable<ExecutableElement> methods,
  Iterable<StreamedCacheMethod> streamedCacheMethods,
) {
  for (final method in methods) {
    final methodName = method.name;
    final referencingStreamedCacheMethods =
        streamedCacheMethods.where((s) => s.targetMethodName == methodName);

    if (referencingStreamedCacheMethods
            .where((s) => s.targetMethodName == methodName)
            .length >
        1) {
      throw InvalidGenerationSourceError(
        '[ERROR] `$methodName` cannot be targeted by multiple @StreamedCache methods',
        element: method,
      );
    }
  }
}

void assertOneCachePeekPerCachedMethod(
  Iterable<ExecutableElement> methods,
  Iterable<CachePeekMethod> cachePeekMethods,
) {
  for (final method in methods) {
    final methodName = method.name;
    final referencingCachePeekMethods =
        cachePeekMethods.where((s) => s.targetMethodName == methodName);

    if (referencingCachePeekMethods
            .where((s) => s.targetMethodName == methodName)
            .length >
        1) {
      throw InvalidGenerationSourceError(
        '[ERROR] `$methodName` cannot be targeted by multiple @CachePeek methods',
        element: method,
      );
    }
  }
}

void assertCorrectStreamMethodType(ExecutableElement element) {
  if (!element.isAbstract) {
    throw InvalidGenerationSourceError(
      '[ERROR] `${element.name}` must be a abstract method',
      element: element,
    );
  }
}

void assertCorrectCachePeekMethodType(ExecutableElement element) {
  if (!element.isAbstract) {
    throw InvalidGenerationSourceError(
      '[ERROR] `${element.name}` must be a abstract method',
      element: element,
    );
  }
}

void assertCorrectDeletesCacheMethodType(ExecutableElement element) {
  if (element.isAbstract) {
    throw InvalidGenerationSourceError(
      '[ERROR] `${element.name}` cant be an abstract method',
      element: element,
    );
  }
}

void assertValidateDeletesCacheMethods(
  Iterable<DeletesCacheMethod> deletesCacheMethods,
  Iterable<CachedMethod> methods,
) {
  for (final deletesCacheMethod in deletesCacheMethods) {
    final invalidTargetMethods = deletesCacheMethod.methodsToClear.where(
      (method) => !methods.map((e) => e.name).contains(method),
    );

    if (invalidTargetMethods.isNotEmpty) {
      final message = invalidTargetMethods
          .map(
            (invalidTargetMethod) =>
                "[ERROR] $invalidTargetMethod is not a valid target for ${deletesCacheMethod.name}",
          )
          .join('\n');
      throw InvalidGenerationSourceError(message);
    }

    if (deletesCacheMethod.methodsToClear.isEmpty) {
      throw InvalidGenerationSourceError(
        '[ERROR] No target method names specified for ${deletesCacheMethod.name}',
      );
    }
  }
}
