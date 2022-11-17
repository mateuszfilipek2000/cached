import 'package:analyzer/dart/element/element.dart';
import 'package:cached/src/models/method_base.dart';
import 'package:cached/src/utils/asserts.dart';

abstract class CachedMethod extends MethodBase {
  CachedMethod({
    required this.syncWrite,
    required String name,
    required bool isAsync,
    required bool isGenerator,
    required bool isAbstract,
    required String returnType,
    this.limit,
    this.ttl,
  }) : super(
          name: name,
          isAsync: isAsync,
          isAbstract: isAbstract,
          isGenerator: isGenerator,
          returnType: returnType,
        );

  final bool syncWrite;
  final int? limit;
  final int? ttl;

  static void assertIsValid(ExecutableElement element) {
    assertMethodNotVoid(element);
    assertMethodIsNotAbstract(element);
  }
}
