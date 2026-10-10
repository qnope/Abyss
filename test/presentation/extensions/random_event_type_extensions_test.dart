import 'dart:io';

import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/presentation/extensions/random_event_type_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  test('every event has a short French name', () {
    expect(RandomEventType.warmCurrent.label(fr), 'Courant chaud');
    expect(RandomEventType.wreck.label(fr), 'Épave');
    expect(RandomEventType.predators.label(fr), 'Banc de prédateurs');
    expect(RandomEventType.storm.label(fr), 'Tempête');
    expect(RandomEventType.survivors.label(fr), 'Survivants');
    expect(RandomEventType.caravan.label(fr), 'Caravane de tortues');
    expect(RandomEventType.coldCurrent.label(fr), 'Courant froid');
  });

  test('every event has a short name in English and Spanish', () {
    expect(RandomEventType.predators.label(en), 'Predator Shoal');
    expect(RandomEventType.caravan.label(en), 'Turtle Caravan');
    expect(RandomEventType.warmCurrent.label(es), 'Corriente cálida');
    expect(RandomEventType.survivors.label(es), 'Supervivientes');
  });

  test('every event has its own illustration among the event icons', () {
    expect(
      RandomEventType.warmCurrent.illustration,
      'assets/icons/events/warm_current.svg',
    );
    expect(
      RandomEventType.coldCurrent.illustration,
      'assets/icons/events/cold_current.svg',
    );
    final paths = {
      for (final type in RandomEventType.values) type.illustration,
    };
    expect(paths, hasLength(RandomEventType.values.length));
    for (final path in paths) {
      expect(path, startsWith('assets/icons/events/'));
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });
}
