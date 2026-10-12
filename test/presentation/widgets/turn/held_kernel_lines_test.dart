import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/history_entry_samples.dart';
import '../../../helpers/test_svg_helper.dart';
import 'held_attack_lines_helper.dart';

BaseAssaultEntry _kernel(
  bool won, {
  int after = 2,
  int garrison = 0,
  int dead = 0,
}) => baseAssaultEntry(
  victory: won,
  defending: true,
  post: 'volcanicKernel',
  kernel: (before: 3, after: after),
  lostWithPost: {if (garrison > 0) UnitType.harpoonist: garrison},
  dead: {if (dead > 0) UnitType.guardian: dead},
);

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('a kernel down one level', (t) async {
    await openAttackSummary(t, _kernel(true));

    expect(
      find.text('Nacre a attaqué le Noyau : un niveau perdu'),
      findsOneWidget,
    );
  });

  testWidgets('a kernel down one level names the defenders killed', (t) async {
    await openAttackSummary(t, _kernel(true, dead: 3));

    expect(find.text('3 unités de la garnison perdues'), findsOneWidget);
  });

  testWidgets('a kernel taken names the garrison lost', (t) async {
    await openAttackSummary(t, _kernel(true, after: 0, garrison: 1));

    expect(find.text('Nacre a pris le Noyau'), findsOneWidget);
    expect(find.text('1 unité de la garnison perdue'), findsOneWidget);
  });

  testWidgets('a kernel taken without a garrison loses no unit', (t) async {
    await openAttackSummary(t, _kernel(true, after: 0));

    expect(find.text('Nacre a pris le Noyau'), findsOneWidget);
    expect(find.textContaining('garnison'), findsNothing);
  });

  testWidgets('a kernel that holds repels the attack', (t) async {
    await openAttackSummary(t, _kernel(false));

    expect(
      find.text('Nacre a attaqué le Noyau : attaque repoussée'),
      findsOneWidget,
    );
  });
}
