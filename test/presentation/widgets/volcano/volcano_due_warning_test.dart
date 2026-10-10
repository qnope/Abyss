import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:abyss/domain/volcano/volcano_wave_factory.dart';
import 'package:abyss/presentation/extensions/monster_lair_extensions.dart';
import 'package:abyss/presentation/screens/game/game_screen_turn_helpers.dart';
import 'package:abyss/presentation/widgets/raid/raid_due_warning.dart';
import 'package:abyss/presentation/widgets/volcano/volcano_due_warning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/localized_app.dart';

final _wave = VolcanoWaveFactory.fromKernelLevel(1);

/// Game of turn 12 whose kernel, guarded by [guardians], is hit by a
/// kraken wave at the end of [arrival].
Game _game({int arrival = 12, int guardians = 0}) {
  final player = Player(name: 'Nemo')..volcanoState.announce(_wave, arrival);
  KernelGarrison.stockOf(player)[UnitType.guardian]!.count = guardians;
  return Game.singlePlayer(player)..turn = 12;
}

Widget? _warnings(Game game) => dueWarnings(fr, game, game.humanPlayer);

void main() {
  testWidgets('warns of a wave hitting an unguarded kernel this turn',
      (tester) async {
    final game = _game();
    final warning = _warnings(game);
    expect(warning, isA<VolcanoDueWarning>());
    await tester.pumpWidget(localizedApp(Scaffold(body: warning)));
    expect(
      find.text('Vague sur le Noyau ce tour : ${_wave.waveLabel(fr)}, et '
          'aucune garnison. Le Noyau perdra probablement un niveau.'),
      findsOneWidget,
    );
  });

  test('no warning when a single unit guards the kernel', () {
    final game = _game(guardians: 1);
    expect(VolcanoDueWarning.of(game, game.humanPlayer), isNull);
    expect(_warnings(game), isNull);
  });

  test('no warning while the wave is still on its way', () {
    final game = _game(arrival: 13);
    expect(VolcanoDueWarning.of(game, game.humanPlayer), isNull);
    expect(_warnings(game), isNull);
  });

  test('no warning when no wave is announced', () {
    final game = _game()..humanPlayer.volcanoState.clearIncoming();
    expect(_warnings(game), isNull);
  });

  test('a raid and a wave due together are both listed, raid first', () {
    final game = _game();
    game.humanPlayer.raidState.announce(_wave, 12);
    final warning = _warnings(game);
    expect(warning, isA<Column>());
    final children = (warning! as Column).children;
    expect(children, hasLength(2));
    expect(children.first, isA<RaidDueWarning>());
    expect(children.last, isA<VolcanoDueWarning>());
  });
}
