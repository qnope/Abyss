import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:abyss/domain/volcano/volcano_wave_factory.dart';
import 'package:abyss/presentation/extensions/monster_lair_extensions.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
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

Future<void> _pump(WidgetTester tester, Player player,
        {Locale locale = AbyssLocale.fr}) =>
    tester.pumpWidget(
      localizedApp(locale: locale, Scaffold(
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
    expect(find.text('Garnison'), findsOneWidget);
    expect(find.text('Gardien'), findsOneWidget);
  });

  testWidgets('lists the garrison by type', (tester) async {
    final player = _player(guardians: 3);
    KernelGarrison.stockOf(player)[UnitType.harpoonist]!.count = 5;
    await _pump(tester, player);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('Harponneur'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('says so when the garrison is empty', (tester) async {
    await _pump(tester, _player());
    expect(find.text('Aucune unité en garnison.'), findsOneWidget);
  });

  testWidgets('counts the units of level 3 outside the garrison',
      (tester) async {
    final player = _player(guardians: 3);
    KernelGarrison.stockAt(player, KernelGarrison.volcanoLevel)[UnitType.scout]!
        .count = 8;
    await _pump(tester, player);
    expect(find.text('Hors garnison, au Niveau 3 : 8 unités'), findsOneWidget);
  });

  testWidgets('hides the outside line when no unit is there', (tester) async {
    await _pump(tester, _player(guardians: 3));
    expect(find.textContaining('Hors garnison'), findsNothing);
  });

  testWidgets('speaks English', (tester) async {
    await _pump(tester, _player(), locale: AbyssLocale.en);
    expect(find.text('Garrison'), findsOneWidget);
    expect(find.text('No unit in the garrison.'), findsOneWidget);
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
