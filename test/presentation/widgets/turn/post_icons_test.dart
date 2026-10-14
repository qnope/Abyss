import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/presentation/widgets/common/raster_svg.dart';
import 'package:abyss/presentation/widgets/objective/objective_banner.dart';
import 'package:abyss/presentation/widgets/turn/undefended_post_warning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/history_entry_samples.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';
import '../../../helpers/post_attack_helper.dart';
import '../objective/objective_widget_helpers.dart';
import 'held_attack_lines_helper.dart';

Finder _art(String name) => find.byWidgetPredicate(
    (w) => w is RasterSvg && w.assetPath == 'assets/icons/posts/$name.svg');

BaseAssaultEntry _post({required bool taken, String code = 'faille:0'}) =>
    baseAssaultEntry(victory: taken, defending: true, post: code);

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('an undefended post shows the post itself', (t) async {
    final war = PostWar(TransitionBaseType.cheminee, humanHolds: true);
    final warning = UndefendedPostWarning.of(war.game, war.game.humanPlayer)!;
    await t.pumpWidget(localizedApp(Scaffold(body: warning)));
    expect(_art('cheminee_player'), findsOneWidget);
    expect(find.byIcon(Icons.shield_outlined), findsNothing);
  });

  testWidgets('a post taken by a faction shows it lit red', (t) async {
    await openAttackSummary(t, _post(taken: true));
    expect(_art('faille_faction'), findsOneWidget);
  });

  testWidgets('a post held against a faction shows it lit green', (t) async {
    await openAttackSummary(t, _post(taken: false, code: 'cheminee:1'));
    expect(_art('cheminee_player'), findsOneWidget);
  });

  testWidgets('the objective to take the Faille shows the Faille', (t) async {
    final game = gameWithCompleted(ObjectiveId.takeFaille.index);
    await t.pumpWidget(objectiveApp(
        ObjectiveBanner(game: game, player: game.humanPlayer)));
    expect(_art('faille_guarded'), findsOneWidget);
  });
}
