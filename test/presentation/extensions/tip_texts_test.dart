import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/event/event_rules.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/objective/tip/event_tips.dart';
import 'package:abyss/domain/objective/tip/tip_category.dart';
import 'package:abyss/domain/objective/tip/tip_id.dart';
import 'package:abyss/presentation/extensions/building_type_extensions.dart';
import 'package:abyss/presentation/extensions/random_event_type_extensions.dart';
import 'package:abyss/presentation/extensions/tip_texts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  final languages = {'fr': fr, 'en': en, 'es': es};

  group('TipCategoryLabel', () {
    test('names the sections of the Guide', () {
      expect(TipCategory.values.map((c) => c.label(fr)), [
        'Base',
        'Menaces',
        'Carte',
        'Événements',
      ]);
      expect(TipCategory.threats.label(en), 'Threats');
      expect(TipCategory.events.label(es), 'Eventos');
    });
  });

  group('TipIdText', () {
    test('every tip has a title and 2 or 3 short lines', () {
      for (final MapEntry(key: language, value: l10n) in languages.entries) {
        for (final id in TipId.values) {
          final reason = '$language ${id.name}';
          expect(id.title(l10n), isNotEmpty, reason: reason);
          expect(id.lines(l10n).length, inInclusiveRange(2, 3), reason: reason);
          for (final line in id.lines(l10n)) {
            expect(line.length, lessThanOrEqualTo(120), reason: line);
          }
        }
      }
    });

    test('names the buildings as the base shows them', () {
      for (final l10n in languages.values) {
        expect(
          TipId.raidAnnounced.lines(l10n).join(' '),
          contains(BuildingType.coralCitadel.displayName(l10n)),
        );
        expect(
          TipId.descent.lines(l10n).join(' '),
          contains(BuildingType.descentModule.displayName(l10n)),
        );
      }
    });

    test('titles each event tip after its event', () {
      for (final l10n in languages.values) {
        for (final type in RandomEventType.values) {
          expect(EventTips.idOf(type).title(l10n), type.label(l10n));
        }
      }
    });

    test('fills in the rules of the game', () {
      expect(
        TipId.noiseGauge.lines(fr).last,
        'Quand la jauge atteint 40, les monstres l\'entendent : un raid est '
        'annoncé.',
      );
      expect(
        TipId.events.lines(en).first,
        'Every ${EventRules.minGap} to ${EventRules.maxGap} turns, an event '
        'shakes the abyss.',
      );
      expect(
        TipId.lastChance.lines(fr).first,
        'Ta base a perdu 2 raids d\'affilée.',
      );
      expect(
        TipId.wreck.lines(es).last,
        'Registrarlo hace ruido (+${EventRules.wreckNoise}): elige tu momento.',
      );
    });

    test('speaks English and Spanish', () {
      expect(TipId.noiseGauge.title(en), 'The noise gauge');
      expect(
        TipId.raidAnnounced.lines(en).first,
        'Your noise drew monsters: they will strike your base in 2 turns.',
      );
      expect(TipId.techChoice.title(es), 'Las elecciones de la investigación');
      expect(
        TipId.storm.lines(es).first,
        'La tormenta cierra la exploración durante 2 turnos.',
      );
    });
  });
}
