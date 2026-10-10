import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/volcano_report.dart';
import 'package:abyss/domain/volcano/volcano_wave_factory.dart';
import 'package:abyss/presentation/extensions/monster_lair_extensions.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/screens/game/game_screen_turn_flow.dart';
import 'package:abyss/presentation/screens/game/volcano/volcano_summary_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/sheet_opener.dart';
import '../../../helpers/test_svg_helper.dart';
import '../../../helpers/transition_fight_fixtures.dart';

final _wave = VolcanoWaveFactory.fromKernelLevel(3);

/// End of turn 41, where a kraken wave hit a level 3 kernel.
TurnResult _result({bool? victory, bool announced = false}) => TurnResult(
      changes: const [],
      previousTurn: 41,
      newTurn: 42,
      hadRecruitedUnits: false,
      announcedWave: announced ? _wave : null,
      volcano: victory == null
          ? null
          : VolcanoReport(
              turn: 41,
              victory: victory,
              wave: _wave,
              fight: buildTestFight(playerWins: victory),
              kernelLevel: 3,
              defenders: const {UnitType.guardian: 2},
              survivorsIntact: const {UnitType.guardian: 1},
              wounded: const {},
              dead: const {UnitType.guardian: 1},
            ),
    );

Future<void> _endTurn(WidgetTester tester, TurnResult result) async {
  useTallView(tester);
  final game = Game.singlePlayer(Player(name: 'Nemo'));
  await openSheet(tester, AbyssLocale.fr, (context) {
    showTurnOutcome(context, game, FakeGameRepository(), result, () {});
  });
}

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('a lost wave is told in the summary, then its report opens',
      (tester) async {
    await _endTurn(tester, _result(victory: false));
    expect(find.text('Volcan : le Noyau retombe au niveau 2'), findsOneWidget);
    expect(find.byType(VolcanoSummaryScreen), findsNothing);

    await _tap(tester, 'OK');
    expect(find.byType(VolcanoSummaryScreen), findsOneWidget);
    expect(find.text('Vague sur le Noyau (tour 41)'), findsOneWidget);
    expect(find.text('Le Noyau retombe au niveau 2'), findsOneWidget);

    await _tap(tester, 'Retour à la base');
    expect(find.byType(VolcanoSummaryScreen), findsNothing);
  });

  testWidgets('a repelled wave stays a line of the summary', (tester) async {
    await _endTurn(tester, _result(victory: true));
    expect(find.text('Volcan : vague repoussée, 0 blessé, 1 mort'),
        findsOneWidget);

    await _tap(tester, 'OK');
    expect(find.byType(VolcanoSummaryScreen), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('the summary announces the wave rising for the next turn',
      (tester) async {
    await _endTurn(tester, _result(announced: true));
    expect(find.text('Aucun changement ce tour.'), findsNothing);
    expect(
      find.text('Le Kraken remonte : ${_wave.waveLabel(fr)} au prochain tour'),
      findsOneWidget,
    );

    await _tap(tester, 'OK');
    expect(find.byType(VolcanoSummaryScreen), findsNothing);
  });
}
