import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/raid/raid_report.dart';
import 'package:abyss/domain/raid/raid_state.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/extensions/monster_lair_extensions.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/screens/game/raid/raid_summary_screen.dart';
import 'package:abyss/presentation/widgets/raid/noise_cost_row.dart';
import 'package:abyss/presentation/widgets/raid/raid_due_warning.dart';
import 'package:abyss/presentation/widgets/raid/raid_status_bar.dart';
import 'package:abyss/presentation/widgets/raid/raid_turn_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';
import '../../../helpers/transition_fight_fixtures.dart';

const _wave = MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 22);

Future<void> _pump(WidgetTester tester, Widget child, Locale locale) =>
    tester.pumpWidget(localizedApp(Scaffold(body: child), locale: locale));

RaidReport _report({required bool victory, bool surprise = false}) =>
    RaidReport(
      turn: 9,
      victory: victory,
      wave: _wave,
      fight: buildTestFight(playerWins: victory, finalMonsters: 1),
      rampartLevel: 2,
      defenders: const {UnitType.guardian: 2},
      survivorsIntact: const {UnitType.guardian: 1},
      wounded: const {UnitType.guardian: 1},
      dead: const {},
      loot: const {},
      pillaged: const {ResourceType.algae: 30},
      surprise: surprise,
    );

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('status bar in English', (tester) async {
    final state = RaidState()
      ..announce(_wave, 14)
      ..recordOutcome(victory: false);
    await _pump(tester, RaidStatusBar(state: state, currentTurn: 13),
        AbyssLocale.en);
    expect(find.text('Raid at the end of turn 14: ${_wave.waveLabel(en)}'),
        findsOneWidget);
    expect(find.text('Raids lost in a row: 1/3'), findsOneWidget);
  });

  testWidgets('status bar in Spanish', (tester) async {
    final state = RaidState()..addNoise(5);
    await _pump(tester, RaidStatusBar(state: state, currentTurn: 13),
        AbyssLocale.es);
    expect(find.text('Ruido'), findsOneWidget);
    state.announce(_wave, 13);
    await _pump(tester, RaidStatusBar(state: state, currentTurn: 13),
        AbyssLocale.es);
    expect(
      find.text('Incursión al final de este turno: ${_wave.waveLabel(es)}'),
      findsOneWidget,
    );
  });

  testWidgets('noise cost in English', (tester) async {
    await _pump(tester, const NoiseCostRow(noise: 3), AbyssLocale.en);
    expect(find.text('Noise'), findsOneWidget);
  });

  testWidgets('due warning names the attacker and the defenders',
      (tester) async {
    await _pump(
      tester,
      const RaidDueWarning(wave: _wave, defenderCount: 0, lastChance: true),
      AbyssLocale.en,
    );
    expect(
      find.text('Raid this turn: ${_wave.waveLabel(en)} against no defender'),
      findsOneWidget,
    );
    expect(find.text('If this raid is lost, the game is over.'),
        findsOneWidget);
    await _pump(
      tester,
      const RaidDueWarning(wave: _wave, defenderCount: 2, predators: true),
      AbyssLocale.es,
    );
    expect(
      find.text('Banco de depredadores este turno: '
          '${_wave.waveLabel(es)} contra 2 defensores'),
      findsOneWidget,
    );
  });

  testWidgets('turn section in Spanish', (tester) async {
    final result = TurnResult(
      changes: const [],
      previousTurn: 4,
      newTurn: 5,
      hadRecruitedUnits: false,
      announcedRaid: _wave,
      announcedRaidTurn: 7,
    );
    await _pump(tester, RaidTurnSection(result: result), AbyssLocale.es);
    expect(
      find.text('Se acerca una incursión: ${_wave.waveLabel(es)}, '
          'final del turno 7'),
      findsOneWidget,
    );
  });

  testWidgets('raid report in French', (tester) async {
    useTallView(tester);
    await _pump(tester, RaidSummaryScreen(report: _report(victory: false)),
        AbyssLocale.fr);
    expect(find.text('Raid sur la base (tour 9)'), findsOneWidget);
    expect(find.text('Rempart de la Citadelle niv. 2'), findsOneWidget);
    expect(find.text('Pillage'), findsOneWidget);
    expect(find.text('Retour à la base'), findsOneWidget);
  });

  testWidgets('raid report in English', (tester) async {
    useTallView(tester);
    await _pump(tester,
        RaidSummaryScreen(report: _report(victory: true, surprise: true)),
        AbyssLocale.en);
    expect(find.text('Predator Shoal (turn 9)'), findsOneWidget);
    expect(find.text('Citadel Rampart lv. 2'), findsOneWidget);
    expect(find.text('No loot'), findsOneWidget);
    expect(find.text('Enemies killed: 3/4'), findsOneWidget);
  });

  testWidgets('raid report in Spanish', (tester) async {
    useTallView(tester);
    await _pump(tester, RaidSummaryScreen(report: _report(victory: false)),
        AbyssLocale.es);
    expect(find.text('Incursión en la base (turno 9)'), findsOneWidget);
    expect(find.text('Saqueo'), findsOneWidget);
    expect(find.text('Algas -30'), findsOneWidget);
  });
}
