import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/objective/tip/tip_id.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/extensions/building_type_extensions.dart';
import 'package:abyss/presentation/extensions/tip_id_extensions.dart';
import 'package:abyss/presentation/extensions/tip_texts.dart';
import 'package:abyss/presentation/extensions/unit_type_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  const posts = [
    TipId.admiral,
    TipId.postDefence,
    TipId.kernelGarrison,
    TipId.postLost,
  ];

  test('each tip of the posts has a title and three lines', () {
    for (final l10n in [fr, en, es]) {
      for (final id in posts) {
        expect(id.title(l10n), isNotEmpty);
        expect(id.lines(l10n), hasLength(3), reason: id.name);
      }
    }
  });

  test('words them in French', () {
    expect(TipId.admiral.title(fr), "L'Amiral");
    expect(
      TipId.admiral.lines(fr).first,
      "L'Amiral des Abysses ne combat pas : il commande l'assaut.",
    );
    expect(TipId.postDefence.title(fr), 'Défendre ses postes');
    expect(
      TipId.postDefence.lines(fr).first,
      'Seules tes unités du niveau du dessous défendent un poste.',
    );
    expect(TipId.kernelGarrison.title(fr), 'La garnison du Noyau');
    expect(TipId.kernelGarrison.lines(fr).last, contains('Mettre en garnison'));
    expect(TipId.postLost.title(fr), 'Poste perdu');
  });

  test('speaks English and Spanish', () {
    expect(TipId.admiral.title(en), 'The Admiral');
    expect(TipId.postDefence.title(en), 'Defending your posts');
    expect(TipId.kernelGarrison.title(es), 'La guarnición del Núcleo');
    expect(TipId.postLost.title(es), 'Puesto perdido');
  });

  test('names the units and buildings as the game shows them', () {
    for (final l10n in [fr, en, es]) {
      expect(
        TipId.admiral.lines(l10n).join(' '),
        contains(UnitType.guardian.displayName(l10n)),
      );
      expect(
        TipId.postDefence.lines(l10n).join(' '),
        contains(BuildingType.descentModule.displayName(l10n)),
      );
      expect(
        TipId.postLost.lines(l10n).join(' '),
        contains(UnitType.abyssAdmiral.displayName(l10n)),
      );
    }
  });

  test('shows the admiral, the module, the kernel and a hostile faction', () {
    expect(TipId.admiral.illustration, UnitType.abyssAdmiral.iconPath);
    expect(TipId.postDefence.illustration, BuildingType.descentModule.iconPath);
    expect(
      TipId.kernelGarrison.illustration,
      BuildingType.volcanicKernel.iconPath,
    );
    expect(
      TipId.postLost.illustration,
      'assets/icons/map_content/faction_hostile.svg',
    );
  });
}
