import 'package:abyss/domain/objective/guide/guide_message.dart';
import 'package:abyss/domain/objective/installation_objectives.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/presentation/extensions/guide_message_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  group('the lessons of the tutorial', () {
    const words = {
      ObjectiveId.hqLevel1: ['QG', 'un seul par tour', '« Tour suivant »'],
      ObjectiveId.algaeFarm: ['algues nourrissent ton armée'],
      ObjectiveId.mines: ['Mine de corail', 'Extracteur', 'plus cher'],
      ObjectiveId.solarPanel: ['énergie', 'Extracteur', 'Caserne'],
      ObjectiveId.hqLevel2: ['QG niveau 2', 'Caserne', 'Laboratoire', 'bruit'],
      ObjectiveId.barracksAndScouts: ['2 Éclaireurs', 'algues', 'bruit'],
      ObjectiveId.explore: ['brouillard', 'repaires', 'familles', 'coffres'],
      ObjectiveId.laboratoryAndResearch: [
        'Une seule recherche par tour',
        'définitifs',
      ],
      ObjectiveId.firstRaid: ['2 tours', 'Harponneurs', 'Citadelle'],
    };
    for (final MapEntry(key: id, value: expected) in words.entries) {
      test(id.name, () {
        final text = GuideLesson(id).text(fr);
        for (final word in expected) {
          expect(text, contains(word));
        }
        expect('.'.allMatches(text).length, inInclusiveRange(2, 3));
      });
    }

    test('one per tutorial objective in every language, none after', () {
      for (final l10n in [fr, en, es]) {
        for (final objective in installationObjectives) {
          expect(objective.id.lesson(l10n), isNotEmpty);
        }
        expect(ObjectiveId.takeLair.lesson(l10n), isNull);
      }
    });

    test('speak English and Spanish', () {
      expect(
        const GuideLesson(ObjectiveId.barracksAndScouts).text(en),
        'Build the Barracks, then recruit 2 Scouts in the Army tab. Every '
        'unit eats algae each turn, and every recruit raises the noise.',
      );
      expect(
        const GuideLesson(ObjectiveId.hqLevel2).text(es),
        startsWith('El Cuartel General de nivel 2 desbloquea los Barracones'),
      );
    });
  });

  group('the words for what holds an objective back', () {
    test('in French', () {
      expect(
        const GuideGoalMet().text(fr),
        'Bravo, c\'est fait ! Termine le tour pour valider l\'objectif et '
        'toucher ta récompense.',
      );
      expect(const GuideWorksiteTaken().text(fr), contains('chantier du tour'));
      expect(const GuideAlreadyRecruited().text(fr), contains('déjà recruté'));
      expect(const GuideExploring().text(fr), contains('en route'));
      expect(
        const GuideStorm(8).text(fr),
        'Une tempête ferme l\'exploration jusqu\'à la fin du tour 8. '
        'Patiente : l\'objectif t\'attend, termine le tour.',
      );
      expect(
        const GuideWreck(9, hasBarracks: false).text(fr),
        allOf(contains('fin du tour 9'), contains('Caserne')),
      );
      expect(
        const GuideWreck(9, hasBarracks: true).text(fr),
        contains('Recrute un Éclaireur'),
      );
    });

    test('in English and Spanish', () {
      expect(
        const GuideExploring().text(en),
        'Your Scout is on its way. End the turn to find out what the tile '
        'hides.',
      );
      expect(
        const GuideWreck(9, hasBarracks: true).text(es),
        'Un pecio se ha hundido cerca de tu base, visible hasta el final del '
        'turno 9. Recluta un Explorador en la pestaña Ejército para ir a '
        'registrarlo.',
      );
    });
  });

  group('the first raid', () {
    test('names the harpoonists missing', () {
      expect(
        const GuideRaidAlert(
          12,
          28,
          needed: 5,
          missing: 2,
          canRecruit: true,
        ).text(fr),
        'Le raid arrive au tour 12 avec 28 monstres. Aie au moins 5 '
        'Harponneurs au niveau 1 : il t\'en manque 2. Recrute-les dans '
        'l\'onglet Armée.',
      );
      expect(
        const GuideRaidAlert(
          12,
          1,
          needed: 1,
          missing: 1,
          canRecruit: true,
        ).text(fr),
        'Le raid arrive au tour 12 avec 1 monstre. Aie au moins 1 '
        'Harponneur au niveau 1 : il t\'en manque 1. Recrute-le dans '
        'l\'onglet Armée.',
      );
    });

    test('once recruited this turn: the rest next turn, or hold on', () {
      expect(
        const GuideRaidAlert(12, 28, needed: 5, missing: 2).text(fr),
        endsWith('Tu as déjà recruté ce tour : recrute-les au prochain tour.'),
      );
      expect(
        const GuideRaidAlert(
          10,
          28,
          needed: 5,
          missing: 2,
          lastTurn: true,
        ).text(fr),
        endsWith('Tu as déjà recruté ce tour : termine-le et tiens bon.'),
      );
    });

    test('a base strong enough, or a wave out of reach', () {
      expect(
        const GuideRaidAlert(12, 28, needed: 5).text(fr),
        'Le raid arrive au tour 12 avec 28 monstres. Ta défense devrait le '
        'repousser : termine le tour pour l\'attendre.',
      );
      expect(
        const GuideRaidAlert(12, 400).text(fr),
        allOf(contains('400 monstres'), contains('autant de Harponneurs')),
      );
    });

    test('in English and Spanish', () {
      const alert = GuideRaidAlert(
        12,
        28,
        needed: 5,
        missing: 1,
        canRecruit: true,
      );
      expect(
        alert.text(en),
        'The raid arrives on turn 12 with 28 monsters. Have at least 5 '
        'Harpooners on level 1: you\'re 1 short. Recruit it in the Army tab.',
      );
      expect(
        alert.text(es),
        'La incursión llega en el turno 12 con 28 monstruos. Ten al menos 5 '
        'Arponeros en el nivel 1: te falta 1. Reclútalo en la pestaña '
        'Ejército.',
      );
    });
  });
}
