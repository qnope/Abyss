import 'package:abyss/domain/faction/faction.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/theme/faction_colors.dart';
import 'package:abyss/presentation/widgets/faction/faction_attack_banner.dart';
import 'package:abyss/presentation/widgets/faction/faction_attack_bars.dart';
import 'package:abyss/presentation/widgets/faction/faction_attack_sheet.dart';
import 'package:abyss/presentation/widgets/unit/unit_count_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/announce_attack_helper.dart';
import '../../../helpers/base_attack_helper.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';
import '../../../helpers/two_player_game.dart';

const FactionPersonality _cult = FactionPersonality.anglerCult;

const Map<UnitType, int> _mixed = {
  UnitType.harpoonist: 30,
  UnitType.guardian: 1,
};

TwoPlayerGame _game() {
  final two = announceGame(rivalId: const Faction(_cult).id);
  station(two.rival, {...raiders, UnitType.guardian: 1});
  two.game.savedFactions = [_cult];
  return two;
}

Future<void> _pump(WidgetTester tester, TwoPlayerGame two) => tester.pumpWidget(
  localizedApp(
    Scaffold(body: FactionAttackBars(game: two.game, player: two.human)),
  ),
);

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('no banner while no attack is announced', (tester) async {
    await _pump(tester, _game());
    expect(find.byType(FactionAttackBanner), findsNothing);
  });

  testWidgets('the banner names the faction, the date and the army', (
    tester,
  ) async {
    final two = _game();
    announce(army: _mixed).execute(two.game, two.rival);
    await _pump(tester, two);

    expect(find.textContaining(_cult.label), findsOneWidget);
    expect(
      find.text('${_cult.label} attaque : fin du tour 14, dans 2 tours'),
      findsOneWidget,
    );
    expect(find.text('Armée : 30 harponneurs, 1 gardien'), findsOneWidget);
  });

  testWidgets('the banner wears the colour of the faction', (tester) async {
    final two = _game();
    announce().execute(two.game, two.rival);
    await _pump(tester, two);

    final text = tester.widget<Text>(find.textContaining('attaque : fin'));
    expect(text.style?.color, FactionColors.of(_cult));
  });

  testWidgets('the arrival turn reads "this turn" on the day', (tester) async {
    final two = _game();
    announce().execute(two.game, two.rival);
    two.game.turn = 14;
    await _pump(tester, two);
    expect(find.textContaining('ce tour'), findsOneWidget);
  });

  testWidgets('tapping the banner opens the exact army', (tester) async {
    final two = _game();
    announce(army: _mixed).execute(two.game, two.rival);
    await _pump(tester, two);

    await tester.tap(find.byType(FactionAttackBanner));
    await tester.pumpAndSettle();

    expect(find.byType(FactionAttackSheet), findsOneWidget);
    expect(find.text('Attaque de ${_cult.label}'), findsOneWidget);
    expect(find.byType(UnitCountRow), findsNWidgets(2));
    expect(find.text('30 harponneurs'), findsOneWidget);
    expect(find.text('1 gardien'), findsOneWidget);
  });

  testWidgets('two attacks make two banners', (tester) async {
    final two = _game();
    announce().execute(two.game, two.rival);
    two.human.raidState.attacks.add(two.human.raidState.attacks.first);
    await _pump(tester, two);
    expect(find.byType(FactionAttackBanner), findsNWidgets(2));
  });
}
