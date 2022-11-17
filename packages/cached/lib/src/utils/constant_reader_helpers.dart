import 'package:analyzer/dart/constant/value.dart';
import 'package:source_gen/source_gen.dart';

class CachedAnnotationProperties {
  final bool syncWrite;
  final int? limit;
  final int? ttl;

  CachedAnnotationProperties({
    this.syncWrite = false,
    this.limit,
    this.ttl,
  });
}

Iterable<String>? readStringList(
  DartObject? annotation,
  String fieldName,
) {
  final reader = ConstantReader(annotation);
  final methodsToClear = reader.read('methodNames');

  if (methodsToClear.isList) {
    return methodsToClear.listValue.map(
      (e) => e.toStringValue()!,
    );
  }

  return null;
}

CachedAnnotationProperties? readCacheAnnotationProperties(
  DartObject? annotation,
) {
  if (annotation == null) {
    return null;
  }

  final reader = ConstantReader(annotation);
  final syncWriteField = reader.read('syncWrite');
  final limitField = reader.read('limit');
  final ttlField = reader.read('ttl');

  return CachedAnnotationProperties(
    syncWrite: syncWriteField.isBool && syncWriteField.boolValue,
    limit: limitField.isInt ? limitField.intValue : null,
    ttl: ttlField.isInt ? ttlField.intValue : null,
  );
}

String? readString(
  DartObject? annotation,
  String fieldName,
) {
  final reader = ConstantReader(annotation);
  final value = reader.read(fieldName);

  if (value.isString) {
    return value.stringValue;
  }

  return null;
}
