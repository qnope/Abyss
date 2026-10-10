import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/game/save_outcome.dart';
import 'package:abyss/presentation/extensions/save_summary_extensions.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';
import '../../helpers/save_summary_helpers.dart';

void main() {
  group('a game in progress', () {
    final summary = summaryOf(difficulty: Difficulty.easy);

    test('is badged with its difficulty', () {
      expect(summary.badgeLabel(fr), 'FACILE');
      expect(summary.badgeColor, AbyssColors.success);
    });

    test('tells its turn, depth and headquarters', () {
      expect(summary.metaLine(fr), 'Tour 14 · Profondeurs · QG niv. 3');
    });

    test('shows its resources rather than a footnote', () {
      expect(summary.footnote(fr), isNull);
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
      expect(summary.badgeLabel(fr), '★ VICTOIRE');
      expect(summary.badgeColor, AbyssColors.energyYellow);
    });

    test('tells its turn, depth and difficulty', () {
      expect(summary.metaLine(fr), 'Tour 63 · Noyau · Facile');
    });

    test('tells whether the volcanic kernel was conquered', () {
      expect(summary.footnote(fr), 'Victoire');
      final conquered = summaryOf(
        outcome: SaveOutcome.victory,
        volcanicKernelCaptured: true,
      );
      expect(conquered.footnote(fr), 'Noyau Volcanique conquis');
    });
  });

  group('a game won then played on', () {
    final summary = summaryOf(
      outcome: SaveOutcome.freePlay,
      difficulty: Difficulty.easy,
    );

    test('is still badged as a victory in gold', () {
      expect(summary.badgeLabel(fr), '★ VICTOIRE');
      expect(summary.badgeColor, AbyssColors.energyYellow);
    });

    test('tells its turn, depth and headquarters like a game in progress', () {
      expect(summary.metaLine(fr), 'Tour 14 · Profondeurs · QG niv. 3');
    });

    test('shows its resources rather than a footnote', () {
      expect(summary.footnote(fr), isNull);
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
      expect(summary.badgeLabel(fr), 'DÉFAITE');
      expect(summary.badgeColor, AbyssColors.error);
    });

    test('tells the turn its base fell on', () {
      expect(summary.metaLine(fr), 'Tombée au tour 27 · Surface · Difficile');
    });

    test('invites to look at its report', () {
      expect(summary.footnote(fr), 'Voir le bilan de la partie');
    });
  });

  test('names who plays, the turn and the difficulty', () {
    final summary = summaryOf(difficulty: Difficulty.hard);
    expect(summary.resumeLabel(fr), 'Alice · Tour 14 · Difficile');
  });

  group('in English', () {
    test('a game in progress', () {
      final summary = summaryOf(difficulty: Difficulty.easy);
      expect(summary.badgeLabel(en), 'EASY');
      expect(summary.resumeLabel(en), 'Alice · Turn 14 · Easy');
    });

    test('a won game', () {
      final summary = summaryOf(
        outcome: SaveOutcome.victory,
        volcanicKernelCaptured: true,
      );
      expect(summary.badgeLabel(en), '★ VICTORY');
      expect(summary.footnote(en), 'Volcanic Core conquered');
    });

    test('a lost game', () {
      final summary = summaryOf(
        outcome: SaveOutcome.defeat,
        turn: 27,
        difficulty: Difficulty.hard,
      );
      expect(summary.badgeLabel(en), 'DEFEAT');
      expect(summary.metaLine(en), startsWith('Fell on turn 27 · '));
      expect(summary.metaLine(en), endsWith(' · Hard'));
      expect(summary.footnote(en), 'See the game report');
    });
  });

  group('in Spanish', () {
    test('a game in progress', () {
      final summary = summaryOf(difficulty: Difficulty.easy);
      expect(summary.metaLine(es), startsWith('Turno 14 · '));
      expect(summary.metaLine(es), endsWith(' · CG niv. 3'));
    });

    test('a won game', () {
      final summary = summaryOf(outcome: SaveOutcome.victory);
      expect(summary.badgeLabel(es), '★ VICTORIA');
      expect(summary.footnote(es), 'Victoria');
    });
  });
}
