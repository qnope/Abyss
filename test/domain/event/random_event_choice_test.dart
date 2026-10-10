import 'package:abyss/domain/event/random_event_choice.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every event asks for a choice but the storm and the wreck', () {
    const withoutChoice = {RandomEventType.storm, RandomEventType.wreck};
    for (final type in RandomEventType.values) {
      expect(
        type.hasChoice,
        !withoutChoice.contains(type),
        reason: type.name,
      );
    }
  });
}
