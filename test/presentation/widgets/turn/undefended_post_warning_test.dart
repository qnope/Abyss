import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/l10n/app_localizations.dart';
import 'package:abyss/presentation/screens/game/game_screen_turn_helpers.dart';
import 'package:abyss/presentation/widgets/turn/turn_confirmation_dialog.dart';
import 'package:abyss/presentation/widgets/turn/undefended_post_warning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/post_attack_helper.dart';

const _failleLine = "Ta Faille n'a aucun défenseur au niveau 2";
const _chemineeLine = "Ta Cheminée n'a aucun défenseur au niveau 3";

/// What the player answered the last confirmation opened by [_confirm].
bool? _confirmed;

/// Opens the end-of-turn confirmation of [game] with its warnings.
Future<void> _confirm(WidgetTester tester, Game game) async {
  _confirmed = null;
  await tester.pumpWidget(
    localizedApp(
      Scaffold(
        body: Builder(
          builder:
              (ctx) => ElevatedButton(
                onPressed:
                    () async =>
                        _confirmed = await showTurnConfirmationDialog(
                          ctx,
                          currentTurn: game.turn,
                          production: const {},
                          raidWarning: dueWarnings(fr, game, game.humanPlayer),
                        ),
                child: const Text('Open'),
              ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('warns of a Faille nobody defends, and still ends the turn', (
    tester,
  ) async {
    final war = PostWar(TransitionBaseType.faille, humanHolds: true);
    await _confirm(tester, war.game);
    expect(find.text(_failleLine), findsOneWidget);
    await tester.tap(find.text('Confirmer'));
    await tester.pumpAndSettle();
    expect(find.text(_failleLine), findsNothing);
    expect(_confirmed, isTrue);
  });

  testWidgets('warns of a Cheminée nobody defends', (tester) async {
    final war = PostWar(TransitionBaseType.cheminee, humanHolds: true);
    await _confirm(tester, war.game);
    expect(find.text(_chemineeLine), findsOneWidget);
  });

  testWidgets('one line per undefended post', (tester) async {
    final war = PostWar(TransitionBaseType.cheminee, humanHolds: true);
    final rift = PostWar(TransitionBaseType.faille).at; // Same map seed.
    war.game.levels[1]!.cellAt(rift.x, rift.y).transitionBase!.capturedBy =
        war.human.id;
    war.human.buildings[BuildingType.descentModule] = Building(
      type: BuildingType.descentModule,
      level: 1,
    );
    await _confirm(tester, war.game);
    expect(find.text(_failleLine), findsOneWidget);
    expect(find.text(_chemineeLine), findsOneWidget);
  });

  testWidgets('no line once a unit defends the post', (tester) async {
    final war = PostWar(TransitionBaseType.faille, humanHolds: true);
    war.put(war.human, 2, {UnitType.guardian: 1});
    expect(UndefendedPostWarning.of(war.game, war.human), isNull);
    await _confirm(tester, war.game);
    expect(find.text(_failleLine), findsNothing);
  });

  testWidgets('no line while the passage is at level 0', (tester) async {
    final war = PostWar(TransitionBaseType.faille, humanHolds: true);
    war.human.buildings[war.passage]!.level = 0;
    expect(UndefendedPostWarning.of(war.game, war.human), isNull);
    await _confirm(tester, war.game);
    expect(find.text(_failleLine), findsNothing);
  });

  test('worded in every language', () {
    String line(AppLocalizations l10n, String kind, int level) =>
        l10n.undefendedPostWarning(kind, level);
    expect(line(fr, 'faille', 2), _failleLine);
    expect(line(fr, 'cheminee', 3), _chemineeLine);
    expect(line(en, 'faille', 2), 'Your Rift has no defender on level 2');
    expect(line(en, 'cheminee', 3), 'Your Vent has no defender on level 3');
    expect(line(es, 'faille', 2), 'Tu Falla no tiene defensores en el nivel 2');
    expect(
      line(es, 'cheminee', 3),
      'Tu Chimenea no tiene defensores en el nivel 3',
    );
  });
}
