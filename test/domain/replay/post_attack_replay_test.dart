import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/replay/replay_export.dart';
import 'package:abyss/domain/script/action_codec.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/post_attack_helper.dart';
import 'live_game_helper.dart';

PostWar _scene() {
  final war = PostWar(TransitionBaseType.faille);
  war.arm(war.attacker, {UnitType.harpoonist: 30});
  war.put(war.owner, 2, {UnitType.guardian: 12, UnitType.harpoonist: 12});
  return war;
}

Map<String, Object?> _state(PostWar war) => <String, Object?>{
  'attacker': snapshotOf(war.game, of: war.attacker),
  'owner': snapshotOf(war.game, of: war.owner),
  'holder': war.post.capturedBy == war.attacker.id ? 'attacker' : 'owner',
};

void main() {
  test('a post attack in the journal replays to the same state', () {
    final live = _scene();
    final result = ActionExecutor().execute(
      live.strike({UnitType.harpoonist: 30}, seed: 9),
      live.game,
      live.attacker,
    );
    expect(result.isSuccess, isTrue);

    final json = ReplayExport.toJson(live.game);
    final written = (json['turns'] as Map)['12'] as List;
    final entry = written.single as Map<String, Object?>;
    expect(entry['do'], 'attackPost');
    expect(entry['seed'], 9);
    expect(entry['player'], live.attacker.id);
    expect(json['exact'], isTrue);

    final replayed = _scene();
    final action = ActionCodec.decode(entry)(Random(1));
    ActionExecutor().execute(action, replayed.game, replayed.attacker);

    expect(_state(replayed), _state(live));
  });
}
