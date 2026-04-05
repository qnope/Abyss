import 'resource_type.dart';

class ProductionFormula {
  final ResourceType resourceType;
  final int Function(int level) _compute;

  const ProductionFormula({
    required this.resourceType,
    required int Function(int level) compute,
  }) : _compute = compute;

  int compute(int level) => level <= 0 ? 0 : _compute(level);
}
