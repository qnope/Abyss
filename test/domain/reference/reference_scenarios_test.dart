import 'dart:io';

import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_tree.dart';
import 'package:flutter_test/flutter_test.dart';

import 'committed_games.dart';

/// What the strategies never play, the scenarios of `reference/scenarios`
/// add to the reference games.
void main() {
  final List<CommittedGame> games = committedGames();

  group('the reference games of reference/games', () {
    test('hold what no strategy plays, through a scenario: troops sent '
        'as reinforcements and called back', () {
      final Set<Object?> verbs = {
        for (final g in games) ...g.humanMoves.map((m) => m['do']),
      };

      expect(verbs, containsAll(['reinforce', 'withdraw']));
    });

    test('answer yes and no to an event', () {
      final Set<Object?> answers = {
        for (final g in games)
          ...g.moves.where((m) => m['do'] == 'event').map((m) => m['accept']),
      };

      expect(answers, {true, false});
    });

    test('research every node of every branch with its option B, in one '
        'game, where the strategies mostly take A', () {
      final CommittedGame game = games.firstWhere(
        (g) => g.name == 'every-research-option-b',
      );

      for (final TechBranch branch in TechBranch.values) {
        final List<Object?> options = [
          for (final Map<String, Object?> m in game.humanMoves)
            if (m['do'] == 'research' && m['branch'] == branch.name)
              m['option'],
        ];
        expect(options, List.filled(TechTree.maxLevel, 'b'), reason: '$branch');
      }
      expect(
        games
            .expand((g) => g.humanMoves)
            .where((m) => m['do'] == 'research' && !m.containsKey('option')),
        isNotEmpty,
      );
    });

    test('use every scenario of reference/scenarios', () {
      final Set<String?> used = games.map((g) => g.source.scenario).toSet();

      for (final FileSystemEntity f
          in Directory('reference/scenarios').listSync()) {
        expect(
          used,
          contains('reference/scenarios/${f.uri.pathSegments.last}'),
        );
      }
    });
  });
}
