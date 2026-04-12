import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/volcanic_kernel_costs.dart';
import 'package:abyss/domain/resource/resource_type.dart';

void main() {
  group('volcanicKernelCost', () {
    test('level 0: coral=50, ore=40, energy=30, pearl=8', () {
      final cost = volcanicKernelCost(0);
      expect(cost[ResourceType.coral], 50);
      expect(cost[ResourceType.ore], 40);
      expect(cost[ResourceType.energy], 30);
      expect(cost[ResourceType.pearl], 8);
    });

    test('level 9: coral=4100, ore=3280, energy=2460, pearl=35', () {
      final cost = volcanicKernelCost(9);
      expect(cost[ResourceType.coral], 4100);
      expect(cost[ResourceType.ore], 3280);
      expect(cost[ResourceType.energy], 2460);
      expect(cost[ResourceType.pearl], 35);
    });

    test('all pearl costs from level 0-9 are <= 100', () {
      for (var level = 0; level < 10; level++) {
        final cost = volcanicKernelCost(level);
        expect(
          cost[ResourceType.pearl]! <= 100,
          isTrue,
          reason: 'pearl cost at level $level is ${cost[ResourceType.pearl]}',
        );
      }
    });
  });
}
