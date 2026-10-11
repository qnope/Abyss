import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';

void main() {
  group('Resource', () {
    test('creates with required fields', () {
      final r = Resource(type: ResourceType.algae, amount: 100);
      expect(r.type, ResourceType.algae);
      expect(r.amount, 100);
    });

    test('defaults: maxStorage=500', () {
      final r = Resource(type: ResourceType.algae, amount: 50);
      expect(r.maxStorage, 500);
    });

    test('accepts custom maxStorage', () {
      final r = Resource(
        type: ResourceType.coral,
        amount: 200,
        maxStorage: 1000,
      );
      expect(r.maxStorage, 1000);
    });

    test('energy storage never drops below the research cost ceiling', () {
      // A save made when the cap was 1000 must still pay 1048 energy.
      final r = Resource(
        type: ResourceType.energy,
        amount: 0,
        maxStorage: 1000,
      );
      expect(r.maxStorage, Resource.minEnergyStorage);
      expect(Resource.minEnergyStorage, 2000);
    });

    test('amount is mutable', () {
      final r = Resource(type: ResourceType.ore, amount: 10);
      r.amount = 20;
      expect(r.amount, 20);
    });
  });
}
