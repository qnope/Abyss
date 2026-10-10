import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:abyss/domain/volcano/volcano_report.dart';
import 'package:abyss/domain/volcano/volcano_wave_factory.dart';
import 'package:abyss/presentation/extensions/monster_lair_extensions.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/screens/game/volcano/volcano_summary_screen.dart';
import 'package:abyss/presentation/widgets/volcano/volcano_due_warning.dart';
import 'package:abyss/presentation/widgets/volcano/volcano_status_bar.dart';
import 'package:abyss/presentation/widgets/volcano/volcano_turn_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';
import '../../../helpers/transition_fight_fixtures.dart';

final _wave = VolcanoWaveFactory.fromKernelLevel(1);

Future<void> _pump(WidgetTester tester, Widget child, Locale locale) =>
    tester.pumpWidget(localizedApp(Scaffold(body: child), locale: locale));

VolcanoReport _report({required bool victory}) => VolcanoReport(
      turn: 41,
      victory: victory,
      wave: _wave,
      fight: buildTestFight(playerWins: victory),
      kernelLevel: 3,
      defenders: const {UnitType.guardian: 2},
      survivorsIntact: const {UnitType.guardian: 2},
      wounded: const {},
      dead: const {},
    );

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('status bar in English', (tester) async {
    final player = Player(name: 'Nemo');
    KernelGarrison.stockOf(player)[UnitType.guardian]!.count = 7;
    player.volcanoState.announce(_wave, 41);
    final level = KernelGarrison.kernelLevelOf(player);
    await _pump(tester, VolcanoStatusBar(player: player), AbyssLocale.en);
    expect(
      find.text('Core lv. $level, end of turn: ${_wave.waveLabel(en)} '
          'against a garrison of 7'),
      findsOneWidget,
    );
  });

  testWidgets('due warning in Spanish', (tester) async {
    await _pump(tester, VolcanoDueWarning(wave: _wave), AbyssLocale.es);
    expect(
      find.text('Oleada sobre el Núcleo este turno: ${_wave.waveLabel(es)}, '
          'y sin guarnición. El Núcleo probablemente perderá un nivel.'),
      findsOneWidget,
    );
  });

  testWidgets('turn section in each language', (tester) async {
    final result = TurnResult(
      changes: const [],
      previousTurn: 40,
      newTurn: 41,
      hadRecruitedUnits: false,
      announcedWave: _wave,
    );
    await _pump(tester, VolcanoTurnSection(result: result), AbyssLocale.fr);
    expect(find.text('Le Kraken remonte : ${_wave.waveLabel(fr)} '
        'au prochain tour'), findsOneWidget);
    await _pump(tester, VolcanoTurnSection(result: result), AbyssLocale.en);
    expect(find.text('The Kraken rises: ${_wave.waveLabel(en)} next turn'),
        findsOneWidget);
  });

  testWidgets('turn section tells the losses of a repelled wave',
      (tester) async {
    final report = VolcanoReport(
      turn: 41,
      victory: true,
      wave: _wave,
      fight: buildTestFight(playerWins: true),
      kernelLevel: 3,
      defenders: const {UnitType.guardian: 4},
      survivorsIntact: const {UnitType.guardian: 1},
      wounded: const {UnitType.guardian: 1},
      dead: const {UnitType.guardian: 2},
    );
    final result = TurnResult(
      changes: const [],
      previousTurn: 41,
      newTurn: 42,
      hadRecruitedUnits: false,
      volcano: report,
    );
    await _pump(tester, VolcanoTurnSection(result: result), AbyssLocale.fr);
    expect(find.text('Volcan : vague repoussée, 1 blessé, 2 morts'),
        findsOneWidget);
    await _pump(tester, VolcanoTurnSection(result: result), AbyssLocale.es);
    expect(find.text('Volcán: oleada repelida, 1 herido, 2 muertos'),
        findsOneWidget);
  });

  testWidgets('wave report in English', (tester) async {
    useTallView(tester);
    await _pump(tester, VolcanoSummaryScreen(report: _report(victory: true)),
        AbyssLocale.en);
    expect(find.text('Wave on the Core (turn 41)'), findsOneWidget);
    expect(find.text('The Core holds at level 3'), findsOneWidget);
    expect(find.textContaining('Magma rampart: '), findsOneWidget);
    expect(find.text('Back to base'), findsOneWidget);
  });

  testWidgets('wave report in Spanish', (tester) async {
    useTallView(tester);
    await _pump(tester, VolcanoSummaryScreen(report: _report(victory: false)),
        AbyssLocale.es);
    expect(find.text('Oleada sobre el Núcleo (turno 41)'), findsOneWidget);
    expect(find.text('El Núcleo cae al nivel 2'), findsOneWidget);
  });
}
