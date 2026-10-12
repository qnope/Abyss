import 'package:abyss/domain/leviathan/leviathan_announcement.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/widgets/common/game_status_bars.dart';
import 'package:abyss/presentation/widgets/leviathan/leviathan_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../domain/leviathan/leviathan_scene.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/post_attack_helper.dart';
import '../../../helpers/test_svg_helper.dart';

const _title = 'Contre-attaque sur la Faille à la fin du tour';

Widget _bar(PostWar war, {void Function(LeviathanAnnouncement)? onOpen}) =>
    localizedApp(
      Scaffold(
        body: LeviathanStatusBar(game: war.game, onOpen: onOpen),
      ),
    );

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('nothing before the turn the guardians strike', (t) async {
    final war = leviathanScene();
    war.playUntil(war.strikeTurn - 1);
    expect(LeviathanStatusBar.isShown(war.game), isFalse);
    await t.pumpWidget(_bar(war));
    expect(find.text(_title), findsNothing);
  });

  testWidgets('on that turn: the force and the defenders of level 2', (
    t,
  ) async {
    final war = leviathanScene();
    war.playUntil(war.strikeTurn);
    war.put(war.human, 2, {UnitType.harpoonist: 3, UnitType.guardian: 2});
    expect(LeviathanStatusBar.isShown(war.game), isTrue);
    await t.pumpWidget(_bar(war));
    expect(find.text(_title), findsOneWidget);
    expect(
      find.text('Léviathan + 4 Sentinelles · défenseurs niv. 2 : 5'),
      findsOneWidget,
    );
  });

  testWidgets('tapping it opens the Faille', (t) async {
    final war = leviathanScene();
    war.playUntil(war.strikeTurn);
    LeviathanAnnouncement? opened;
    await t.pumpWidget(_bar(war, onOpen: (a) => opened = a));
    await t.tap(find.text(_title));
    expect(opened!.at, war.at);
    expect(opened!.level, war.level);
  });

  testWidgets('speaks English', (t) async {
    final war = leviathanScene();
    war.playUntil(war.strikeTurn);
    await t.pumpWidget(
      localizedApp(
        Scaffold(body: LeviathanStatusBar(game: war.game)),
        locale: AbyssLocale.en,
      ),
    );
    expect(
      find.text('Counter-attack on the Rift at the end of the turn'),
      findsOneWidget,
    );
    expect(
      find.text('Leviathan + 4 Sentinels · level 2 defenders: 0'),
      findsOneWidget,
    );
  });

  testWidgets('stands among the strips under the resources', (t) async {
    final war = leviathanScene();
    war.playUntil(war.strikeTurn);
    int? level;
    await t.pumpWidget(
      localizedApp(
        Scaffold(
          body: GameStatusBars(
            game: war.game,
            player: war.human,
            onOpenMap: (l) => level = l,
          ),
        ),
      ),
    );
    await t.tap(find.text(_title));
    expect(level, war.level);
  });
}
