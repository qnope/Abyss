import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/widgets/map/exploration_sheet.dart';
import 'package:abyss/presentation/widgets/map/monster_lair_sheet.dart';
import 'package:abyss/presentation/widgets/map/treasure_sheet.dart';
import 'package:abyss/presentation/widgets/map/volcanic_kernel_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/sheet_opener.dart';
import '../../../helpers/test_svg_helper.dart';

void _explore(BuildContext context) => showExplorationSheet(
      context,
      targetX: 3,
      targetY: 8,
      scoutCount: 2,
      revealSide: 3,
      isEligible: true,
      onConfirm: () {},
    );

void _kernel(BuildContext context, {required bool captured}) =>
    showVolcanicKernelSheet(
      context,
      isCaptured: captured,
      player: Player(name: 'Nemo'),
      onAttack: () {},
      onGarrison: () {},
      onWithdraw: () {},
    );

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('exploration sheet in English and Spanish', (tester) async {
    await openSheet(tester, AbyssLocale.en, _explore);
    expect(find.text('Explore (3, 8)'), findsOneWidget);
    expect(find.text('Cost'), findsOneWidget);
    expect(find.text('1 scout'), findsOneWidget);
    expect(find.text('Scouts available'), findsOneWidget);
    expect(find.text('3×3 cells'), findsOneWidget);
    expect(find.text('Send'), findsOneWidget);
    await openSheet(tester, AbyssLocale.es, _explore);
    expect(find.text('Explorar (3, 8)'), findsOneWidget);
    expect(find.text('Zona revelada'), findsOneWidget);
    expect(find.text('3×3 casillas'), findsOneWidget);
  });

  testWidgets('treasure sheet in English and Spanish', (tester) async {
    void show(BuildContext context) => showTreasureSheet(
          context,
          targetX: 1,
          targetY: 2,
          contentType: CellContentType.ruins,
          onCollect: () {},
        );
    await openSheet(tester, AbyssLocale.en, show);
    expect(find.text('Treasure (1, 2)'), findsOneWidget);
    expect(find.text('Coral, ore and pearls'), findsOneWidget);
    expect(find.text('Collect the treasure'), findsOneWidget);
    await openSheet(tester, AbyssLocale.es, show);
    expect(find.text('Tesoro (1, 2)'), findsOneWidget);
    expect(find.text('Recoger el tesoro'), findsOneWidget);
  });

  testWidgets('lair sheet in English and Spanish', (tester) async {
    void show(BuildContext context) => showMonsterLairSheet(
          context,
          targetX: 1,
          targetY: 2,
          lair: const MonsterLair(
            difficulty: MonsterDifficulty.easy,
            unitCount: 3,
            family: MonsterFamily.swarm,
          ),
          onPrepareFight: () {},
        );
    await openSheet(tester, AbyssLocale.en, show);
    expect(find.text('Difficulty'), findsOneWidget);
    expect(find.text('Level'), findsOneWidget);
    expect(find.text('Units'), findsOneWidget);
    expect(find.text('HP / ATK / DEF'), findsOneWidget);
    expect(find.textContaining('Weak against: '), findsOneWidget);
    expect(find.text('Prepare the fight'), findsOneWidget);
    await openSheet(tester, AbyssLocale.es, show);
    expect(find.text('Dificultad'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Preparar el combate'), findsOneWidget);
  });

  testWidgets('kernel sheet before its capture in English', (tester) async {
    await openSheet(tester, AbyssLocale.en, (c) => _kernel(c, captured: false));
    expect(find.text('Volcanic Core'), findsOneWidget);
    expect(
      find.text('The burning heart of the abyss is held by powerful '
          'guardians.'),
      findsOneWidget,
    );
    expect(find.text('Launch the assault'), findsOneWidget);
  });

  testWidgets('kernel sheet once captured in Spanish', (tester) async {
    await openSheet(tester, AbyssLocale.es, (c) => _kernel(c, captured: true));
    expect(find.text('Núcleo Volcánico'), findsOneWidget);
    expect(find.textContaining('Has capturado el Núcleo Volcánico.'),
        findsOneWidget);
    final level = KernelGarrison.kernelLevelOf(Player(name: 'Nemo'));
    expect(find.text('Núcleo nivel $level'), findsOneWidget);
    expect(find.text('Guarnición: 0 unidades'), findsOneWidget);
    expect(find.text('Poner en guarnición'), findsOneWidget);
    expect(find.text('Retirar'), findsOneWidget);
  });
}
