import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/replay/replay_export.dart';
import 'package:abyss/domain/script/action_codec.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/kernel_war_helper.dart';
import 'live_game_helper.dart';

KernelWar _scene() => KernelWar(kernelLevel: 2)
  ..arm({UnitType.harpoonist: 40})
  ..garrison({UnitType.guardian: 6, UnitType.harpoonist: 6});

Map<String, Object?> _state(KernelWar war) => <String, Object?>{
  'attacker': snapshotOf(war.game, of: war.attacker),
  'owner': snapshotOf(war.game, of: war.owner),
  'holder': war.holder == war.attacker.id ? 'attacker' : 'owner',
  'kernel': war.kernelOf(war.owner),
};

void main() {
  test('a kernel attack in the journal replays to the same state', () {
    final live = _scene();
    final result = ActionExecutor().execute(
      live.strike({UnitType.harpoonist: 40}, seed: 9),
      live.game,
      live.attacker,
    );
    expect(result.isSuccess, isTrue);

    final json = ReplayExport.toJson(live.game);
    final written = (json['turns'] as Map)['12'] as List;
    final entry = written.single as Map<String, Object?>;
    expect(entry['do'], 'attackHeldKernel');
    expect(entry['seed'], 9);
    expect(entry['player'], live.attacker.id);
    expect(json['exact'], isTrue);

    final replayed = _scene();
    final action = ActionCodec.decode(entry)(Random(1));
    ActionExecutor().execute(action, replayed.game, replayed.attacker);

    expect(_state(replayed), _state(live));
  });
}
