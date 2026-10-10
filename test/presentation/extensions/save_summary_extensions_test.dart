import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/game/save_outcome.dart';
import 'package:abyss/presentation/extensions/save_summary_extensions.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/save_summary_helpers.dart';

void main() {
  group('a game in progress', () {
    final summary = summaryOf(difficulty: Difficulty.easy);

    test('is badged with its difficulty', () {
      expect(summary.badgeLabel, 'FACILE');
      expect(summary.badgeColor, AbyssColors.success);
    });

    test('tells its turn, depth and headquarters', () {
      expect(summary.metaLine, 'Tour 14 · Profondeurs · QG niv. 3');
    });

    test('shows its resources rather than a footnote', () {
      expect(summary.footnote, isNull);
    });

    test('pictures the depth reached', () {
      expect(summary.thumbnail, endsWith('depth_deep.svg'));
    });
  });

  group('a won game', () {
    final summary = summaryOf(
      outcome: SaveOutcome.victory,
      turn: 63,
      deepestLevel: 3,
      difficulty: Difficulty.easy,
    );

    test('is badged as a victory in gold', () {
      expect(summary.badgeLabel, '★ VICTOIRE');
      expect(summary.badgeColor, AbyssColors.energyYellow);
    });

    test('tells its turn, depth and difficulty', () {
      expect(summary.metaLine, 'Tour 63 · Noyau · Facile');
    });

    test('tells whether the volcanic kernel was conquered', () {
      expect(summary.footnote, 'Victoire');
      final conquered = summaryOf(
        outcome: SaveOutcome.victory,
        volcanicKernelCaptured: true,
      );
      expect(conquered.footnote, 'Noyau volcanique conquis');
    });
  });

  group('a lost game', () {
    final summary = summaryOf(
      outcome: SaveOutcome.defeat,
      turn: 27,
      deepestLevel: 1,
      difficulty: Difficulty.hard,
    );

    test('is badged as a defeat in red', () {
      expect(summary.badgeLabel, 'DÉFAITE');
      expect(summary.badgeColor, AbyssColors.error);
    });

    test('tells the turn its base fell on', () {
      expect(summary.metaLine, 'Tombée au tour 27 · Surface · Difficile');
    });

    test('invites to look at its report', () {
      expect(summary.footnote, 'Voir le bilan de la partie');
    });
  });
}
