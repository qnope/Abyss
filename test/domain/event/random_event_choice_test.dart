import 'package:abyss/domain/event/random_event_choice.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every event asks for a choice except the storm', () {
    for (final type in RandomEventType.values) {
      expect(type.hasChoice, type != RandomEventType.storm, reason: type.name);
    }
  });
}
