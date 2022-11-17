import 'package:meta/meta_meta.dart';

/// ADD DOCS
@Target({TargetKind.method, TargetKind.getter})
class ModifiesCache {
  /// {@macro cached.modifies_cache}
  const ModifiesCache(this.methodNames);

  /// Name of methods whose cache is altered by this method
  final List<String> methodNames;
}
