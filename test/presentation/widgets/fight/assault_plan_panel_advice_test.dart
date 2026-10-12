import 'package:abyss/domain/fight/assault/assault_target.dart';
import 'package:abyss/presentation/widgets/fight/assault_check_row.dart';
import 'package:flutter_test/flutter_test.dart';

import 'assault_plan_panel_helper.dart';

void main() {
  group('the next step', () {
    testWidgets('warns when the headquarters are too low', (tester) async {
      await pump(tester, plan(strong));
      const title = 'Ensuite : Module de Descente';
      expect(stateOf(tester, title), AssaultCheckState.warning);
      expect(find.text('Il demande le QG 5, tu es au QG 4'), findsOneWidget);
    });

    testWidgets('is ok when the headquarters allow it', (tester) async {
      await pump(tester, plan(strong, hq: 5));
      expect(stateOf(tester, 'Ensuite : Module de Descente'),
          AssaultCheckState.ok);
      expect(find.text('Ton QG 5 le permet déjà'), findsOneWidget);
    });

    testWidgets('is absent for the kernel', (tester) async {
      await pump(tester,
          plan(strong, target: AssaultTarget.kernel, maxHarpoonists: 1));
      expect(find.textContaining('Ensuite'), findsNothing);
    });
  });

  group('the advice', () {
    testWidgets('names the escort and the harpoonists', (tester) async {
      await pump(tester, plan({admiral: 1, guardian: 4, harpoonist: 2}));
      expect(find.text("Conseil : l'Amiral avec 4 gardiens, 10 harponneurs"),
          findsOneWidget);
    });

    testWidgets('advises harpoonists alone without guardians',
        (tester) async {
      await pump(tester, plan({harpoonist: 2}, stock: const {}));
      expect(find.textContaining("Conseil : l'Amiral avec"), findsOneWidget);
      expect(find.textContaining('gardien'), findsNothing);
    });

    testWidgets('is absent when out of reach', (tester) async {
      await pump(tester,
          plan(strong, target: AssaultTarget.kernel, maxHarpoonists: 1));
      expect(find.textContaining('Conseil'), findsNothing);
    });
  });
}
