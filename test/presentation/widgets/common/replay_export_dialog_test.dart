import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/common/replay_export_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget build(Game game) => MaterialApp(
    theme: AbyssTheme.create(),
    home: Scaffold(body: ReplayExportDialog(game: game)),
  );

  testWidgets('describes the replay file of a new game', (tester) async {
    await tester.pumpWidget(
      build(GameFactory.newSinglePlayer(playerName: 'Nemo', mapSeed: 1)),
    );

    expect(find.textContaining('replay-Nemo-tour-1.json'), findsOneWidget);
    expect(find.textContaining('à l\'identique'), findsOneWidget);
    expect(find.text('Partager le fichier'), findsOneWidget);
    expect(find.text('Copier'), findsOneWidget);
  });

  testWidgets('copies the replay as text', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    await tester.pumpWidget(
      build(GameFactory.newSinglePlayer(playerName: 'Nemo', mapSeed: 1)),
    );
    await tester.tap(find.text('Copier'));
    await tester.pump();

    expect(copied, contains('"mapSeed": 1'));
  });

  testWidgets('explains why an old game cannot be exported', (tester) async {
    await tester.pumpWidget(
      build(GameFactory.newSinglePlayer(playerName: 'Nemo')..replay = null),
    );

    expect(find.textContaining('avant l\'enregistrement'), findsOneWidget);
    expect(find.text('Partager le fichier'), findsNothing);
  });
}
