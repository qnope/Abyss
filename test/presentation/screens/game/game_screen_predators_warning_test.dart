import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/extensions/monster_lair_extensions.dart';
import 'package:abyss/presentation/screens/game/game_screen_turn_helpers.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/event/event_pending_warning.dart';
import 'package:abyss/presentation/widgets/raid/raid_due_warning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../domain/event/effects/predators_test_helper.dart';
import '../../../helpers/l10n_fixtures.dart';

const _lastChance = 'Si ce raid est perdu, la partie est terminée.';

/// Game of turn 12 whose predators wait, faced when [faced].
Game _game({required bool faced}) {
  final player = threatenedPlayer(units: {UnitType.harpoonist: 3})
    ..raidState.lostInARow = 2;
  if (faced) {
    player.eventState
      ..clearPending()
      ..predatorsTurn = 12;
  }
  return Game.singlePlayer(player)..turn = 12;
}

Future<void> _show(WidgetTester tester, Widget? warning) => tester.pumpWidget(
  MaterialApp(
    theme: AbyssTheme.create(),
    home: Scaffold(body: warning ?? const SizedBox()),
  ),
);

void main() {
  const MonsterLair wave = predatorTestWave;

  testWidgets('warns that the faced predators strike this turn', (
    tester,
  ) async {
    final game = _game(faced: true);
    final warning = dueWarnings(game, game.humanPlayer);
    expect(warning, isA<RaidDueWarning>());
    final raid = warning! as RaidDueWarning;
    expect(raid.lastChance, isFalse);
    expect(raid.defenderCount, 3);
    await _show(tester, warning);
    expect(
      find.text(
        'Banc de prédateurs ce tour : ${wave.waveLabel(fr)} '
        'contre 3 défenseurs',
      ),
      findsOneWidget,
    );
    expect(find.text(_lastChance), findsNothing);
  });

  testWidgets('predators waiting for a choice warn of the prudent option', (
    tester,
  ) async {
    final game = _game(faced: false);
    final warning = dueWarnings(game, game.humanPlayer);
    expect(warning, isA<EventPendingWarning>());
    await _show(tester, warning);
    expect(
      find.text(
        "Banc de prédateurs : sans choix, l'option prudente s'appliquera",
      ),
      findsOneWidget,
    );
    expect(find.textContaining('ce tour :'), findsNothing);
  });

  testWidgets('no warning once nothing waits nor strikes', (tester) async {
    final game = _game(faced: false);
    game.humanPlayer.eventState
      ..clearPending()
      ..clearPredators();
    expect(dueWarnings(game, game.humanPlayer), isNull);
  });

  testWidgets('a raid due this turn still says "Raid"', (tester) async {
    final game = _game(faced: false);
    game.humanPlayer.raidState.announce(wave, 12);
    await _show(tester, dueWarnings(game, game.humanPlayer));
    expect(find.textContaining('Raid ce tour : '), findsOneWidget);
    expect(find.text(_lastChance), findsOneWidget);
  });
}
