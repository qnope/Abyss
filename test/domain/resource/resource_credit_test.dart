import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_credit.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<ResourceType, Resource> resources() => {
    ResourceType.coral: Resource(
      type: ResourceType.coral,
      amount: 90,
      maxStorage: 100,
    ),
    ResourceType.ore: Resource(type: ResourceType.ore, amount: 10),
  };

  test('adds each amount and returns what was added', () {
    final stock = resources();

    final added = ResourceCredit.add(stock, {ResourceType.ore: 20});

    expect(stock[ResourceType.ore]!.amount, 30);
    expect(added, {ResourceType.ore: 20});
  });

  test('stops at the storage cap and reports only what fitted', () {
    final stock = resources();

    final added = ResourceCredit.add(stock, {ResourceType.coral: 30});

    expect(stock[ResourceType.coral]!.amount, 100);
    expect(added, {ResourceType.coral: 10});
  });

  test('a resource the player lacks adds nothing', () {
    final added = ResourceCredit.add(resources(), {ResourceType.algae: 5});

    expect(added, {ResourceType.algae: 0});
  });
}
