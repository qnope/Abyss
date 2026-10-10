import 'package:abyss/domain/event/event_production.dart';
import 'package:abyss/domain/event/event_rules.dart';
import 'package:abyss/domain/event/event_state.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:flutter_test/flutter_test.dart';

Map<ResourceType, int> _production() => {
  ResourceType.algae: 100,
  ResourceType.coral: 50,
  ResourceType.ore: 7,
  ResourceType.energy: 40,
  ResourceType.pearl: 2,
};

EventState _active(RandomEventType type, {bool heating = false}) =>
    EventState()
      ..activate(type, untilTurn: 14)
      ..heating = heating;

void main() {
  test('no lasting event leaves the production as it is', () {
    expect(EventProduction.adjust(_production(), EventState(), 12),
        _production());
    expect(EventProduction.heatingEnergy(EventState(), 12), 0);
  });

  test('a warm current adds 30 % of algae, coral and ore only', () {
    expect(EventRules.currentPercent, 30);
    final adjusted = EventProduction.adjust(
        _production(), _active(RandomEventType.warmCurrent), 14);
    expect(adjusted, {
      ResourceType.algae: 130,
      ResourceType.coral: 65,
      ResourceType.ore: 9,
      ResourceType.energy: 40,
      ResourceType.pearl: 2,
    });
  });

  test('a cold current takes 30 % of the algae only', () {
    final adjusted = EventProduction.adjust(
        _production(), _active(RandomEventType.coldCurrent), 12);
    expect(adjusted, {..._production(), ResourceType.algae: 70});
    expect(
      EventProduction.heatingEnergy(_active(RandomEventType.coldCurrent), 12),
      0,
    );
  });

  test('heated farms keep their algae for energy each turn', () {
    final state = _active(RandomEventType.coldCurrent, heating: true);
    expect(EventProduction.adjust(_production(), state, 12), _production());
    expect(EventProduction.heatingEnergy(state, 12),
        EventRules.heatingEnergyPerTurn);
  });

  test('an effect past its last turn changes nothing', () {
    for (final type in [
      RandomEventType.warmCurrent,
      RandomEventType.coldCurrent,
    ]) {
      final state = _active(type, heating: true);
      expect(EventProduction.adjust(_production(), state, 15), _production());
      expect(EventProduction.heatingEnergy(state, 15), 0);
    }
  });

  test('the other lasting events leave the production as it is', () {
    final state = _active(RandomEventType.storm);
    expect(EventProduction.adjust(_production(), state, 12), _production());
  });
}
