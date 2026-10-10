import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:abyss/presentation/screens/game/game_screen_kernel_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/kernel_garrison_helpers.dart';
import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  late FakeGameRepository repository;
  late int changes;

  setUp(() {
    repository = FakeGameRepository();
    changes = 0;
  });

  Future<void> openPicker(
    WidgetTester tester, Game game, {bool withdraw = false}) async {
    await tester.pumpWidget(localizedApp(Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => handleGarrisonKernel(
            context, game, repository, () => changes++, withdraw: withdraw),
          child: const Text('go'),
        ),
      ),
    )));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
  }

  Future<void> pickAndConfirm(
    WidgetTester tester, int count, String confirm) async {
    for (var i = 0; i < count; i++) {
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
    }
    await tester.tap(find.text('$confirm ($count)'));
    await tester.pumpAndSettle();
  }

  testWidgets('sending units moves them into the garrison and saves',
      (tester) async {
    final game = kernelGarrisonGame(onVolcano: 3);
    await openPicker(tester, game);
    expect(find.text(fr.screenGarrisonSendTitle), findsOneWidget);
    expect(find.text(fr.screenGarrisonSendInfo), findsOneWidget);

    await pickAndConfirm(tester, 2, fr.commonSend);

    expect(KernelGarrison.sizeOf(game.humanPlayer), 2);
    expect(scoutsOnVolcano(game), 1);
    expect(repository.saveCallCount, 1);
    expect(find.text(fr.screenGarrisonSize(2)), findsOneWidget);
    expect(changes, 1);
  });

  testWidgets('cancelling the picker changes nothing', (tester) async {
    final game = kernelGarrisonGame(onVolcano: 3);
    await openPicker(tester, game);
    await tester.tap(find.text(fr.commonCancel));
    await tester.pumpAndSettle();

    expect(KernelGarrison.sizeOf(game.humanPlayer), 0);
    expect(repository.saveCallCount, 0);
    expect(find.byType(SnackBar), findsNothing);
    expect(changes, 0);
  });

  testWidgets('withdrawing units sends them back to the volcano level',
      (tester) async {
    final game = kernelGarrisonGame(onVolcano: 0, garrisoned: 4);
    await openPicker(tester, game, withdraw: true);
    expect(find.text(fr.screenGarrisonWithdrawTitle), findsOneWidget);
    expect(find.text(fr.screenGarrisonWithdrawInfo), findsOneWidget);

    await pickAndConfirm(tester, 1, fr.screenGarrisonWithdraw);

    expect(KernelGarrison.sizeOf(game.humanPlayer), 3);
    expect(scoutsOnVolcano(game), 1);
    expect(repository.saveCallCount, 1);
    expect(find.text(fr.screenGarrisonSize(3)), findsOneWidget);
  });

  testWidgets('an uncaptured kernel refuses the garrison without saving',
      (tester) async {
    final game = kernelGarrisonGame(captured: false, onVolcano: 3);
    await openPicker(tester, game);
    await pickAndConfirm(tester, 1, fr.commonSend);

    expect(scoutsOnVolcano(game), 3);
    expect(repository.saveCallCount, 0);
    expect(find.text(fr.actionFailureKernelNotCaptured), findsOneWidget);
    expect(changes, 1);
  });
}
