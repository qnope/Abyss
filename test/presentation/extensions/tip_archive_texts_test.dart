import 'dart:io';

import 'package:abyss/domain/game/defeat_checker.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/post_holder.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/objective/tip/tip_category.dart';
import 'package:abyss/domain/objective/tip/tip_id.dart';
import 'package:abyss/presentation/extensions/monster_family_extensions.dart';
import 'package:abyss/presentation/extensions/post_holder_extensions.dart';
import 'package:abyss/presentation/extensions/tip_id_extensions.dart';
import 'package:abyss/presentation/extensions/tip_texts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  const archives = [
    TipId.abyssListens,
    TipId.rivalColonies,
    TipId.ancients,
    TipId.forgeTowers,
    TipId.awakening,
  ];

  test('names the Archives section in every language', () {
    expect(TipCategory.archives.label(fr), 'Archives');
    expect(TipCategory.archives.label(en), 'Archives');
    expect(TipCategory.archives.label(es), 'Archivos');
  });

  test('each archive card has a title and three lines', () {
    for (final l10n in [fr, en, es]) {
      for (final id in archives) {
        expect(id.title(l10n), isNotEmpty, reason: id.name);
        expect(id.lines(l10n), hasLength(3), reason: id.name);
      }
    }
  });

  test('tells the lore in French, addressing the player as « tu »', () {
    expect(archives.map((id) => id.title(fr)), [
      'Les abysses écoutent',
      'Les colonies rivales',
      'Les Anciens et leurs perles',
      'Les tours-forges',
      'Le réveil',
    ]);
    expect(
      TipId.rivalColonies.lines(fr).first,
      'Les autres navires du Naufrage se sont posés le même jour que toi.',
    );
    expect(
      TipId.awakening.lines(fr).last,
      "Au dixième feu, la chaleur remonte jusqu'au récif : le Volcan est "
      'dompté.',
    );
  });

  test('speaks English and Spanish', () {
    expect(archives.map((id) => id.title(en)), [
      'The abyss listens',
      'The rival colonies',
      'The Ancients and their pearls',
      'The forge-towers',
      'The awakening',
    ]);
    expect(archives.map((id) => id.title(es)), [
      'Los abismos escuchan',
      'Las colonias rivales',
      'Los Antiguos y sus perlas',
      'Las torres-forja',
      'El despertar',
    ]);
    expect(
      TipId.rivalColonies.lines(es).first,
      'Los demás barcos del Naufragio se posaron el mismo día que tú.',
    );
  });

  test('a dome falls after three raids lost in a row, as told', () {
    expect(DefeatChecker.lostRaidsLimit, 3);
    expect(TipId.abyssListens.lines(fr).last, contains('trois raids'));
  });

  test(
    'shows a swarm, a rival dome, a Faille held, a Cheminée, the Kraken',
    () {
      expect(
        TipId.abyssListens.illustration,
        MonsterFamily.swarm.svgPathAt(MonsterDifficulty.hard),
      );
      expect(
        TipId.rivalColonies.illustration,
        'assets/icons/map_content/faction_neutral.svg',
      );
      expect(
        TipId.ancients.illustration,
        TransitionBaseType.faille.svgPathFor(PostHolder.human),
      );
      expect(
        TipId.forgeTowers.illustration,
        TransitionBaseType.cheminee.svgPathFor(PostHolder.guardians),
      );
      expect(TipId.awakening.illustration, krakenSvgPath);
      for (final id in archives) {
        expect(File(id.illustration).existsSync(), isTrue, reason: id.name);
      }
    },
  );
}
