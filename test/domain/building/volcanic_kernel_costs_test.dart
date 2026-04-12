import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/volcanic_kernel_costs.dart';
import 'package:abyss/domain/resource/resource_type.dart';

void main() {
  group('volcanicKernelCost', () {
    test('level 0: coral=50, ore=40, energy=12, pearl=8', () {
      final cost = volcanicKernelCost(0);
      expect(cost[ResourceType.coral], 50);
      expect(cost[ResourceType.ore], 40);
      expect(cost[ResourceType.energy], 12);
      expect(cost[ResourceType.pearl], 8);
    });

    test('level 9: coral=4100, ore=3280, energy=984, pearl=35', () {
      final cost = volcanicKernelCost(9);
      expect(cost[ResourceType.coral], 4100);
      expect(cost[ResourceType.ore], 3280);
      expect(cost[ResourceType.energy], 984);
      expect(cost[ResourceType.pearl], 35);
    });

    test('all costs from level 0-9 are within storage caps', () {
      const caps = {
        ResourceType.coral: 5000,
        ResourceType.ore: 5000,
        ResourceType.energy: 1000,
        ResourceType.pearl: 100,
      };
      for (var level = 0; level < 10; level++) {
        final cost = volcanicKernelCost(level);
        for (final entry in cost.entries) {
          expect(
            entry.value <= caps[entry.key]!,
            isTrue,
            reason:
                '${entry.key} cost at level $level is ${entry.value}, '
                'cap is ${caps[entry.key]}',
          );
        }
      }
    });
  });
}
