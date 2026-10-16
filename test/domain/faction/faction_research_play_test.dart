import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/faction_game.dart';

void main() {
  test('the standing factions open the Explorer branch by turn 40', () {
    final game = playFactionGame(3, 40);
    final standing = [
      for (final f in game.factions)
        if (!game.players[f.id]!.hasFallen) f,
    ];

    expect(standing, isNotEmpty);
    for (final faction in standing) {
      final explorer =
          game.players[faction.id]!.techBranches[TechBranch.explorer]!;
      expect(explorer.researchLevel, greaterThan(0), reason: faction.name);
    }
  });
}
