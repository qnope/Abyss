import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/resource.dart';
import 'package:abyss/domain/resource_type.dart';

void main() {
  group('Resource', () {
    test('creates with required fields', () {
      final r = Resource(type: ResourceType.algae, amount: 100);
      expect(r.type, ResourceType.algae);
      expect(r.amount, 100);
    });

    test('defaults: productionPerTurn=0, maxStorage=500', () {
      final r = Resource(type: ResourceType.algae, amount: 50);
      expect(r.productionPerTurn, 0);
      expect(r.maxStorage, 500);
    });

    test('accepts custom productionPerTurn and maxStorage', () {
      final r = Resource(
        type: ResourceType.coral,
        amount: 200,
        productionPerTurn: 15,
        maxStorage: 1000,
      );
      expect(r.productionPerTurn, 15);
      expect(r.maxStorage, 1000);
    });

    test('amount is mutable', () {
      final r = Resource(type: ResourceType.ore, amount: 10);
      r.amount = 20;
      expect(r.amount, 20);
    });
  });
}
