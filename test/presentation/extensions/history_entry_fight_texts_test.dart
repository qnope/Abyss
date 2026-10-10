import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/presentation/extensions/history_entry_texts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/history_entry_samples.dart';
import '../../helpers/l10n_fixtures.dart';

void main() {
  test('titles fights after their outcome', () {
    expect(
      combatEntry(victory: true).displayTitle(fr),
      'Victoire vs Repaire niv. 2',
    );
    expect(
      combatEntry(victory: false).displayTitle(en),
      'Defeat vs Lair lv. 2',
    );
    expect(raidEntry(victory: true).displayTitle(fr), 'Raid repoussé');
    expect(
      raidEntry(victory: false).displayTitle(es),
      'Base saqueada por una incursión',
    );
    expect(
      raidEntry(victory: true, surprise: true).displayTitle(fr),
      'Banc de prédateurs repoussé',
    );
    expect(
      raidEntry(victory: false, surprise: true).displayTitle(en),
      'Base looted by a predator shoal',
    );
    expect(
      volcanoEntry(victory: true).displayTitle(fr),
      'Vague repoussée sur le Noyau',
    );
    expect(
      volcanoEntry(victory: false).displayTitle(en),
      'The Core lost a level',
    );
  });

  test('titles captures after the base, or the Volcanic Core', () {
    final base = captureEntry('Faille Alpha');
    expect(base.displayTitle(fr), 'Capture : Faille Alpha');
    expect(base.displayTitle(en), 'Capture: Alpha Rift');
    expect(captureEntry('cheminee:1').displayTitle(es),
        'Captura: Chimenea Secundaria');
    expect(captureEntry('Faille Noire').displayTitle(en),
        'Capture: Faille Noire');
    final kernel = captureEntry(CaptureEntry.volcanicKernel);
    expect(kernel.displayTitle(fr), 'Capture : Noyau Volcanique');
    expect(kernel.displayTitle(es), 'Captura: Núcleo Volcánico');
    expect(base.displaySubtitle(fr), 'Victoire en 2 tours');
    expect(base.displaySubtitle(en), 'Victory in 2 turns');
  });

  test('counts the units of a descent and of reinforcements', () {
    final descent = DescentEntry(turn: 1, targetLevel: 2, unitCount: 1);
    expect(descent.displayTitle(fr), 'Descente au Niveau 2');
    expect(descent.displaySubtitle(fr), '1 unité envoyée');
    expect(descent.displayTitle(en), 'Descent to Level 2');
    final legacy = DescentEntry(
      turn: 1,
      targetLevel: 2,
      unitCount: 4,
      subtitle: '4 unites envoyees',
    );
    expect(legacy.displaySubtitle(en), '4 units sent');
    final sent = ReinforcementEntry(turn: 1, targetLevel: 3, unitCount: 3);
    expect(sent.displayTitle(fr), 'Renforts vers Niveau 3');
    expect(sent.displaySubtitle(fr), '3 unités en transit');
    expect(sent.displaySubtitle(es), '3 unidades en tránsito');
  });

  test('says which choice an event got, when it had one', () {
    EventEntry event({bool accepted = false, bool defaulted = false}) =>
        EventEntry(
          turn: 1,
          type: RandomEventType.caravan,
          accepted: accepted,
          defaulted: defaulted,
        );
    expect(event().displayTitle(en), 'Turtle Caravan');
    expect(event(accepted: true).displaySubtitle(fr), 'Accepté');
    expect(event().displaySubtitle(fr), 'Refusé');
    expect(event().displaySubtitle(es), 'Rechazado');
    expect(
      event(defaulted: true).displaySubtitle(fr),
      'Option prudente, sans choix',
    );
    final storm = EventEntry(
      turn: 1,
      type: RandomEventType.storm,
      accepted: true,
      defaulted: false,
    );
    expect(storm.displaySubtitle(fr), isNull);
  });
}
