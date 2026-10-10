import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/presentation/extensions/random_event_type_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every event has a short French name', () {
    expect(RandomEventType.warmCurrent.label, 'Courant chaud');
    expect(RandomEventType.wreck.label, 'Épave');
    expect(RandomEventType.predators.label, 'Banc de prédateurs');
    expect(RandomEventType.storm.label, 'Tempête');
    expect(RandomEventType.survivors.label, 'Survivants');
    expect(RandomEventType.caravan.label, 'Caravane de tortues');
    expect(RandomEventType.coldCurrent.label, 'Courant froid');
  });
}
