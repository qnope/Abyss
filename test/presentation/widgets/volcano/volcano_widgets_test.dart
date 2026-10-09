import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:abyss/domain/volcano/volcano_wave_factory.dart';
import 'package:abyss/presentation/widgets/volcano/volcano_status_bar.dart';
import 'package:abyss/presentation/widgets/volcano/volcano_turn_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('the status bar shows the wave against the garrison',
      (tester) async {
    final player = Player(name: 'Nemo');
    KernelGarrison.stockOf(player)[UnitType.guardian]!.count = 7;
    player.volcanoState.announce(VolcanoWaveFactory.fromKernelLevel(1), 41);
    await tester.pumpWidget(_wrap(VolcanoStatusBar(player: player)));
    expect(find.textContaining('3 Krakens'), findsOneWidget);
    expect(find.textContaining('garnison de 7'), findsOneWidget);
  });

  testWidgets('the status bar stays empty without a wave', (tester) async {
    await tester.pumpWidget(_wrap(VolcanoStatusBar(player: Player(name: 'N'))));
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('the turn summary announces the next wave', (tester) async {
    final result = TurnResult(
      changes: const [],
      previousTurn: 40,
      newTurn: 41,
      hadRecruitedUnits: false,
      announcedWave: VolcanoWaveFactory.fromKernelLevel(1),
    );
    expect(VolcanoTurnSection.hasContent(result), isTrue);
    await tester.pumpWidget(_wrap(VolcanoTurnSection(result: result)));
    expect(find.textContaining('Le Kraken remonte'), findsOneWidget);
  });
}
