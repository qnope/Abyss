import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/base_assault_summary_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/history_entry_samples.dart';
import '../../../helpers/test_svg_helper.dart';
import 'held_attack_lines_helper.dart';

BaseAssaultEntry _post(
  bool taken, {
  String code = 'faille:0',
  Map<UnitType, int> lost = const {},
  bool passage = true,
}) => baseAssaultEntry(
  victory: taken,
  defending: true,
  post: code,
  lostWithPost: lost,
  passageDestroyed: passage,
);

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('a Faille taken names the passage and the units lost', (t) async {
    await openAttackSummary(t, _post(true, lost: const {UnitType.scout: 4}));

    expect(find.text('Nacre a pris ta Faille Alpha'), findsOneWidget);
    expect(find.text('Module de descente détruit'), findsOneWidget);
    expect(find.text('4 unités du niveau 2 perdues'), findsOneWidget);
  });

  testWidgets('a Cheminée taken with nobody below loses its capsule only', (
    t,
  ) async {
    await openAttackSummary(t, _post(true, code: 'cheminee:0'));

    expect(find.text('Nacre a pris ta Cheminée Primaire'), findsOneWidget);
    expect(find.text('Capsule pressurisée détruite'), findsOneWidget);
    expect(find.textContaining('perdue'), findsNothing);
  });

  testWidgets('a post held is a repelled attack', (t) async {
    await openAttackSummary(t, _post(false));

    expect(
      find.text('Nacre a attaqué ta Faille Alpha : attaque repoussée'),
      findsOneWidget,
    );
    expect(find.textContaining('détruit'), findsNothing);
  });

  testWidgets('a post of an unknown name is shown as is', (t) async {
    await openAttackSummary(t, _post(true, code: 'Atlantide'));

    expect(find.text('Nacre a pris ta Atlantide'), findsOneWidget);
    expect(find.textContaining('détruit'), findsNothing);
  });

  testWidgets('a post taken before its passage was built loses none', (
    t,
  ) async {
    await openAttackSummary(t, _post(true, passage: false));

    expect(find.text('Nacre a pris ta Faille Alpha'), findsOneWidget);
    expect(find.textContaining('détruit'), findsNothing);
  });

  testWidgets('the button opens the report of the post fight', (t) async {
    await openAttackSummary(t, _post(true));

    await t.tap(find.text('Voir le rapport'));
    await t.pumpAndSettle();

    expect(find.byType(BaseAssaultSummaryScreen), findsOneWidget);
    expect(find.text('Nacre vous a attaqué'), findsOneWidget);
  });
}
