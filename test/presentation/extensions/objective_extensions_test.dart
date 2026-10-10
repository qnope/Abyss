import 'package:abyss/domain/objective/objective_catalog.dart';
import 'package:abyss/domain/objective/objective_chapter.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/presentation/extensions/objective_extensions.dart';
import 'package:abyss/presentation/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';

String _title(ObjectiveId id, AppLocalizations l10n) =>
    ObjectiveCatalog.byId(id).displayTitle(l10n);

void main() {
  group('ObjectiveChapterDisplay', () {
    test('names the six chapters in French', () {
      expect(ObjectiveChapter.values.map((c) => c.title(fr)), [
        'Installation',
        'Le récif',
        'La Faille',
        'La Cheminée',
        'Le Noyau',
        'Le réveil',
      ]);
    });

    test('names them in English and Spanish', () {
      expect(ObjectiveChapter.reef.title(en), 'The Reef');
      expect(ObjectiveChapter.awakening.title(en), 'The Awakening');
      expect(ObjectiveChapter.chimney.title(es), 'La Chimenea');
      expect(ObjectiveChapter.installation.title(es), 'Instalación');
    });

    test('numbers them from 1', () {
      expect(
        ObjectiveChapter.installation.numberedTitle(fr),
        '1. Installation',
      );
      expect(ObjectiveChapter.reef.numberedTitle(en), '2. The Reef');
      expect(ObjectiveChapter.kernel.numberedTitle(es), '5. El Núcleo');
    });
  });

  group('ObjectiveDisplay', () {
    test('words every objective in French, in catalog order', () {
      expect(ObjectiveCatalog.all.map((o) => o.displayTitle(fr)), [
        'Monte le QG au niveau 1',
        'Construis la Ferme d\'algues',
        'Construis la Mine de corail et l\'Extracteur de minerai',
        'Construis le Panneau solaire',
        'Monte le QG au niveau 2',
        'Construis la Caserne et recrute 2 Éclaireurs',
        'Explore une case autour de la base',
        'Construis le Laboratoire et lance une recherche',
        'Repousse le premier raid',
        'Prends un repaire',
        'Monte le QG au niveau 5',
        'Construis la Citadelle corallienne',
        'Prends la Faille',
        'Construis le Module de Descente',
        'Descends au niveau 2',
        'Monte le QG au niveau 8',
        'Prends la Cheminée',
        'Construis la Capsule Pressurisée',
        'Descends au niveau 3',
        'Monte le QG au niveau 10',
        'Prends le Noyau Volcanique',
        'Monte le Noyau au niveau 1',
        'Monte le Noyau au niveau 5',
        'Monte le Noyau au niveau 10',
      ]);
    });

    test('words them in English and Spanish', () {
      expect(_title(ObjectiveId.hqLevel5, en), 'Raise the HQ to level 5');
      expect(
        _title(ObjectiveId.barracksAndScouts, en),
        'Build the Barracks and recruit 2 Scouts',
      );
      expect(_title(ObjectiveId.takeKernel, en), 'Take the Volcanic Core');
      expect(_title(ObjectiveId.descendLevel3, es), 'Desciende al nivel 3');
      expect(_title(ObjectiveId.firstRaid, es), 'Repele la primera incursión');
      expect(
        _title(ObjectiveId.mines, es),
        'Construye la Mina de coral y el Extractor de mineral',
      );
    });

    test('every title is unique and non-empty in each language', () {
      for (final l10n in [fr, en, es]) {
        final titles = ObjectiveCatalog.all.map((o) => o.displayTitle(l10n));
        expect(titles.toSet(), hasLength(ObjectiveId.values.length));
        expect(titles.every((t) => t.isNotEmpty), isTrue);
      }
    });

    test('reads the figure the goal names', () {
      int figure(ObjectiveId id) => ObjectiveCatalog.byId(id).figure;
      expect(figure(ObjectiveId.hqLevel8), 8);
      expect(figure(ObjectiveId.descendLevel2), 2);
      expect(figure(ObjectiveId.barracksAndScouts), 2);
      expect(figure(ObjectiveId.firstRaid), 1);
    });
  });
}
