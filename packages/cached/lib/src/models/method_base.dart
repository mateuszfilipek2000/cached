abstract class MethodBase {
  MethodBase({
    required this.name,
    required this.isAbstract,
    required this.isAsync,
    required this.isGenerator,
    required this.returnType,
  });

  final String name;
  final String returnType;
  final bool isGenerator;
  final bool isAsync;
  final bool isAbstract;
}
