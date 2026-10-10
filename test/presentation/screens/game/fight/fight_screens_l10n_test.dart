import 'package:abyss/domain/action/attack_volcanic_kernel_result.dart';
import 'package:abyss/domain/action/fight_monster_result.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/screens/game/fight/army_selection_screen.dart';
import 'package:abyss/presentation/screens/game/fight/fight_summary_screen.dart';
import 'package:abyss/presentation/screens/game/fight/kernel_army_selection_screen.dart';
import 'package:abyss/presentation/screens/game/fight/kernel_fight_summary_screen.dart';
import 'package:abyss/presentation/screens/game/fight/transition_fight_summary_screen.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../domain/action/fight_monster_action_helper.dart';
import '../../../../helpers/fake_game_repository.dart';
import '../../../../helpers/localized_app.dart';
import '../../../../helpers/test_svg_helper.dart';
import '../../../../helpers/transition_fight_fixtures.dart';

const _lair = MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 3);

FightMonsterResult _fight({required bool victory}) =>
    FightMonsterResult.success(
      victory: victory,
      fight: buildTestFight(playerWins: victory, finalMonsters: 1),
      loot: const {ResourceType.coral: 12},
      sent: const {UnitType.scout: 3},
      survivorsIntact: const {UnitType.scout: 1},
      wounded: const {UnitType.scout: 1},
      dead: const {UnitType.scout: 1},
    );

Future<void> _pump(WidgetTester tester, Widget screen, Locale locale) async {
  useTallView(tester);
  await tester.pumpWidget(localizedApp(screen, locale: locale));
  await tester.pumpAndSettle();
}

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('fight summary in English', (tester) async {
    await _pump(
      tester,
      FightSummaryScreen(result: _fight(victory: true), lair: _lair,
          targetX: 2, targetY: 3),
      AbyssLocale.en,
    );
    expect(find.text('Fight (2, 3)'), findsOneWidget);
    expect(find.text('VICTORY'), findsOneWidget);
    expect(find.text('Fight over 2 turns'), findsOneWidget);
    expect(find.text('Your units'), findsOneWidget);
    expect(find.text('Sent: 3 / Unhurt: 1 / Wounded: 1 / Dead: 1'),
        findsOneWidget);
    expect(find.text('Enemies killed: 3/4'), findsOneWidget);
    expect(find.text('Loot'), findsOneWidget);
    expect(find.text('Turn 1'), findsOneWidget);
    expect(find.text('Allies alive: 3'), findsWidgets);
    expect(find.text('Critical hits: 1'), findsOneWidget);
    expect(find.text('Back to the map'), findsOneWidget);
  });

  testWidgets('fight summary in Spanish', (tester) async {
    await _pump(
      tester,
      FightSummaryScreen(result: _fight(victory: false), lair: _lair,
          targetX: 2, targetY: 3),
      AbyssLocale.es,
    );
    expect(find.text('Combate (2, 3)'), findsOneWidget);
    expect(find.text('DERROTA'), findsOneWidget);
    expect(find.text('Combate en 2 turnos'), findsOneWidget);
    expect(find.text('Enviadas: 3 / Intactas: 1 / Heridas: 1 / Muertas: 1'),
        findsOneWidget);
    expect(find.text('Daño recibido: 5'), findsOneWidget);
    expect(find.text('Golpes críticos: 1'), findsOneWidget);
  });

  testWidgets('kernel assault summary in English', (tester) async {
    final result = AttackVolcanicKernelResult.success(
      victory: true,
      captured: true,
      fight: buildTestFight(playerWins: true),
      sent: const {UnitType.abyssAdmiral: 1},
      survivorsIntact: const {UnitType.abyssAdmiral: 1},
      wounded: const {},
      dead: const {},
    );
    await _pump(
      tester,
      KernelFightSummaryScreen(result: result, targetX: 1, targetY: 1),
      AbyssLocale.en,
    );
    expect(find.text('Assault: Volcanic Core'), findsOneWidget);
    expect(find.text('CORE CAPTURED'), findsOneWidget);
    expect(find.text('Guardians defeated: 4/4'), findsOneWidget);
  });

  testWidgets('transition assault summary in Spanish', (tester) async {
    await _pump(
      tester,
      TransitionFightSummaryScreen(
        result: buildTransitionResult(victory: true, captured: true),
        transitionBase: TransitionBase(
            type: TransitionBaseType.faille, name: 'Faille Alpha'),
        targetX: 4,
        targetY: 5,
      ),
      AbyssLocale.es,
    );
    expect(find.text('Asalto (4, 5)'), findsOneWidget);
    expect(find.text('BASE CAPTURADA'), findsOneWidget);
    expect(find.text('Guardianes eliminados: 4/4'), findsOneWidget);
    expect(find.text('Volver al mapa'), findsOneWidget);
  });

  testWidgets('army selection in English', (tester) async {
    final scenario = createFightScenario(stock: const {UnitType.scout: 3});
    await _pump(
      tester,
      ArmySelectionScreen(game: scenario.game,
          repository: FakeGameRepository(), targetX: 1, targetY: 1,
          level: 1, lair: _lair, onChanged: () {}),
      AbyssLocale.en,
    );
    expect(find.text('Prepare the fight'), findsOneWidget);
    expect(find.text('Start the fight'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Stock: 3'), findsOneWidget);
    expect(find.text('Military bonus: none'), findsOneWidget);
  });

  testWidgets('kernel army selection in Spanish', (tester) async {
    final scenario = createFightScenario(
      stock: const {UnitType.abyssAdmiral: 1},
      content: CellContentType.volcanicKernel,
      withLair: false,
    );
    await _pump(
      tester,
      KernelArmySelectionScreen(game: scenario.game,
          repository: FakeGameRepository(), targetX: 1, targetY: 1,
          level: 1, onChanged: () {}),
      AbyssLocale.es,
    );
    expect(find.text('Asalto: Núcleo Volcánico'), findsOneWidget);
    expect(find.text('Lanzar el asalto'), findsOneWidget);
    expect(
      find.text('Se necesita un Almirante del Abismo para lanzar el asalto'),
      findsOneWidget,
    );
  });
}
