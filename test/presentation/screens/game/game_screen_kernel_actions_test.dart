import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/presentation/screens/game/fight/kernel_army_selection_screen.dart';
import 'package:abyss/presentation/screens/game/game_screen_kernel_actions.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('opens the kernel army selection for the target cell',
      (tester) async {
    final game = Game.singlePlayer(Player(name: 'Nemo'));
    final repository = FakeGameRepository();
    void onChanged() {}

    await tester.pumpWidget(MaterialApp(
      theme: AbyssTheme.create(),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => handleAttackVolcanicKernel(
                context, game, repository, 4, 7, 3, onChanged),
            child: const Text('go'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    final screen = tester.widget<KernelArmySelectionScreen>(
      find.byType(KernelArmySelectionScreen),
    );
    expect(screen.game, same(game));
    expect(screen.repository, same(repository));
    expect((screen.targetX, screen.targetY, screen.level), (4, 7, 3));
    expect(screen.onChanged, same(onChanged));
    expect(find.text('Assaut : Noyau Volcanique'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('go'), findsOneWidget);
  });
}
