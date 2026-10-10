import 'dart:io';

import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/common/replay_export_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _share = MethodChannel('dev.fluttercommunity.plus/share');
const _pathProvider = MethodChannel('plugins.flutter.io/path_provider');

void main() {
  late Directory temp;
  setUp(() => temp = Directory.systemTemp.createTempSync('replay_test'));
  tearDown(() => temp.deleteSync(recursive: true));

  Game newGame() => GameFactory.newSinglePlayer(playerName: 'Nemo', mapSeed: 1);

  Future<void> openDialog(WidgetTester tester, Game game) async {
    await tester.pumpWidget(MaterialApp(
      theme: AbyssTheme.create(),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showReplayExportDialog(context, game),
            child: const Text('export'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('export'));
    await tester.pumpAndSettle();
  }

  void mockChannel(
    WidgetTester tester,
    MethodChannel channel,
    Future<Object?> Function(MethodCall call) handler,
  ) {
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));
  }

  testWidgets('close dismisses the dialog', (tester) async {
    await openDialog(tester, newGame());
    expect(find.text('Exporter la partie'), findsOneWidget);

    await tester.tap(find.text('Fermer'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('counts the recorded actions of every turn', (tester) async {
    final game = newGame()..turn = 3;
    game.replay!.actions
      ..[1] = ['a', 'b']
      ..[2] = ['c'];
    await openDialog(tester, game);
    expect(find.textContaining('contient 3 actions sur 3 tours joués'), findsOneWidget);
  });

  testWidgets('warns when some dice were not recorded', (tester) async {
    await openDialog(tester, newGame()..replay!.exact = false);
    expect(find.textContaining('pourra différer'), findsOneWidget);
  });

  testWidgets('copy closes the dialog and confirms with a snackbar',
      (tester) async {
    mockChannel(tester, SystemChannels.platform, (_) async => null);
    await openDialog(tester, newGame());

    await tester.tap(find.text('Copier'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Replay copié dans le presse-papiers'), findsOneWidget);
  });

  testWidgets('share sends the replay file then closes', (tester) async {
    Map<Object?, Object?>? shared;
    mockChannel(tester, _pathProvider, (_) async => temp.path);
    mockChannel(tester, _share, (call) async {
      shared = call.arguments as Map<Object?, Object?>;
      return 'ok';
    });
    await openDialog(tester, newGame());

    await tester.runAsync(() async {
      await tester.tap(find.text('Partager le fichier'));
      for (var i = 0; i < 50 && shared == null; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });
    await tester.pumpAndSettle();

    expect(shared!['title'], 'Replay Abysses');
    final path = (shared!['paths'] as List).single as String;
    expect(path, endsWith('replay-Nemo-tour-1.json'));
    expect(File(path).readAsStringSync(), contains('"mapSeed": 1'));
    expect(shared!['mimeTypes'], ['application/json']);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
