import 'package:abyss/domain/objective/objective_migration.dart';
import 'package:abyss/domain/objective/tip/tip_catalog.dart';
import 'package:abyss/domain/objective/tip/tip_category.dart';
import 'package:abyss/domain/objective/tip/tip_id.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/announce_attack_helper.dart';
import '../../../helpers/base_attack_helper.dart';
import '../../../helpers/two_player_game.dart';

void main() {
  late TwoPlayerGame two;
  TipId? next() => TipCatalog.nextFor(two.game, two.human)?.id;

  setUp(() {
    two = announceGame();
    station(two.human, {});
    final state = ObjectiveMigration.stateOf(two.game, two.human)
      ..tipsEnabled = true;
    // The other tips of a base at level 5 are out of the way.
    for (final id in TipId.values) {
      if (id != TipId.factionAttack) state.markSeen(id);
    }
  });

  test('is filed with the threats', () {
    expect(TipCatalog.byId(TipId.factionAttack).category, TipCategory.threats);
  });

  test('none while no attack is announced', () {
    expect(next(), isNull);
  });

  test('opens at the first announced attack', () {
    announce().execute(two.game, two.rival);
    expect(next(), TipId.factionAttack);
  });

  test('opens once: seen, it never comes back', () {
    announce().execute(two.game, two.rival);
    ObjectiveMigration.stateOf(
      two.game,
      two.human,
    ).markSeen(TipId.factionAttack);
    expect(next(), isNull);
  });

  test('stays shut while the tips are off', () {
    announce().execute(two.game, two.rival);
    ObjectiveMigration.stateOf(two.game, two.human).tipsEnabled = false;
    expect(next(), isNull);
  });
}
