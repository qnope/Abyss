import 'package:abyss/domain/faction/faction_attack_report.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:abyss/presentation/extensions/attacker_name_texts.dart';
import 'package:abyss/presentation/extensions/history_entry_texts.dart';
import 'package:abyss/presentation/extensions/transition_base_name_extensions.dart';
import 'package:abyss/presentation/screens/game/fight/base_assault_summary_screen.dart';
import 'package:abyss/presentation/widgets/turn/attack_turn_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../domain/leviathan/leviathan_scene.dart';
import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/post_attack_helper.dart';
import '../../../helpers/test_svg_helper.dart';

/// The guardians' attack on an empty level 2: they take the Faille.
(PostWar, FactionAttackReport) _fought() {
  final war = leviathanScene();
  war.playUntil(war.strikeTurn);
  return (war, war.endTurn().report!);
}

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  test('names the guardians in each language, others as they are', () {
    expect(attackerLabel(fr, 'leviathan'), 'Le Léviathan');
    expect(attackerLabel(en, 'leviathan'), 'The Leviathan');
    expect(attackerLabel(es, 'leviathan'), 'El Leviatán');
    expect(attackerLabel(fr, 'Nacre'), 'Nacre');
  });

  testWidgets('the end-of-turn summary reports it once, by name', (t) async {
    final (war, report) = _fought();
    final result = TurnResult(
      changes: const [],
      previousTurn: war.game.turn - 1,
      newTurn: war.game.turn,
      hadRecruitedUnits: false,
      attacks: [report],
      leviathan: report,
    );
    await t.pumpWidget(
      localizedApp(Scaffold(body: AttackTurnSection(result: result))),
    );
    final post = baseNameLabel(fr, war.post.name);
    expect(find.text('Le Léviathan a pris ta $post'), findsOneWidget);
    expect(find.text('Voir le rapport'), findsOneWidget);
  });

  testWidgets('the report names it', (t) async {
    final (_, report) = _fought();
    await t.pumpWidget(
      localizedApp(BaseAssaultSummaryScreen(entry: report.entry)),
    );
    expect(find.text('Assaut : Le Léviathan'), findsOneWidget);
    expect(find.text('Le Léviathan vous a attaqué'), findsOneWidget);
  });

  test('the history names it', () {
    final (war, report) = _fought();
    final post = baseNameLabel(fr, war.post.name);
    expect(report.entry.displayTitle(fr), '$post prise par Le Léviathan');
    expect(war.human.historyEntries.last, same(report.entry));
  });
}
