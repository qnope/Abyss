import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:abyss/domain/volcano/volcano_wave_factory.dart';
import 'package:abyss/presentation/extensions/monster_lair_extensions.dart';
import 'package:abyss/presentation/widgets/volcano/kernel_garrison_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/localized_app.dart';

final _wave = VolcanoWaveFactory.fromKernelLevel(2);

/// Holder of a level 2 kernel guarded by [guardians].
Player _player({int guardians = 0}) {
  final player = Player(name: 'Nemo');
  player.buildings[BuildingType.volcanicKernel] =
      Building(type: BuildingType.volcanicKernel, level: 2);
  KernelGarrison.stockOf(player)[UnitType.guardian]!.count = guardians;
  return player;
}

Future<void> _pump(WidgetTester tester, Player player) => tester.pumpWidget(
      localizedApp(Scaffold(
        body: KernelGarrisonPanel(
          player: player,
          onGarrison: () {},
          onWithdraw: () {},
        ),
      )),
    );

void main() {
  testWidgets('shows the kernel level and its garrison', (tester) async {
    await _pump(tester, _player(guardians: 3));
    expect(find.text('Noyau niveau 2'), findsOneWidget);
    expect(find.text('Garnison : 3 unités'), findsOneWidget);
  });

  testWidgets('announces the next wave and when it hits', (tester) async {
    final player = _player()..volcanoState.announce(_wave, 30);
    await _pump(tester, player);
    expect(
      find.text('Prochaine vague, à la fin du tour : ${_wave.waveLabel(fr)}'),
      findsOneWidget,
    );
  });

  testWidgets('tells how many levels the waves took', (tester) async {
    final player = _player()
      ..volcanoState.recordOutcome(victory: false)
      ..volcanoState.recordOutcome(victory: false);
    await _pump(tester, player);
    expect(find.text('Niveaux perdus face aux vagues : 2'), findsOneWidget);
  });

  testWidgets('a calm kernel never lost tells neither', (tester) async {
    final player = _player()..volcanoState.recordOutcome(victory: true);
    await _pump(tester, player);
    expect(find.textContaining('Prochaine vague'), findsNothing);
    expect(find.textContaining('Niveaux perdus'), findsNothing);
  });
}
