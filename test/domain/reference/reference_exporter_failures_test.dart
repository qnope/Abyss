import 'package:abyss/domain/reference/reference_exporter.dart';
import 'package:abyss/domain/reference/reference_source.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/script/game_script.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tool/reference/sha256_hex.dart';
import 'reference_sources.dart';

/// A script that does [cheat] on turn 2, behind the back of the rules.
class _Cheat extends GameScript {
  final void Function(ScriptTurn turn) cheat;

  const _Cheat(this.cheat);

  @override
  String get name => 'cheat';

  @override
  void playTurn(ScriptTurn turn) {
    if (turn.number == 2) cheat(turn);
  }
}

class _CheatSource extends ReferenceSource {
  final void Function(ScriptTurn turn) cheat;

  const _CheatSource(this.cheat) : super(strategy: 'cheat', turns: 4);

  @override
  GameScript script(String Function(String path) read) => _Cheat(cheat);
}

void _morePearls(ScriptTurn turn) =>
    turn.game.humanPlayer.resources[ResourceType.pearl]!.amount += 1;

Matcher _stateError(String message) => throwsA(
  isA<StateError>().having((e) => e.message, 'message', contains(message)),
);

void main() {
  const exporter = ReferenceExporter(digest: sha256Hex, read: readScenario);
  const strict = ReferenceExporter(
    digest: sha256Hex,
    read: readScenario,
    everyTurn: true,
  );

  test('a game whose journal is not exact is refused', () {
    expect(
      () => exporter.export(
        _CheatSource((turn) => turn.game.replay!.exact = false),
      ),
      _stateError('not exact'),
    );
  });

  test('a game its journal does not replay is refused, naming the '
      'sections that differ once it stopped', () {
    expect(
      () => exporter.export(const _CheatSource(_morePearls)),
      _stateError('The replay differs when it stopped: resources'),
    );
  });

  test('compared at every turn, it names the first turn that differs', () {
    expect(
      () => strict.export(const _CheatSource(_morePearls)),
      _stateError('The replay differs at the start of turn 3: resources'),
    );
  });

  test('a replay that stops on another turn is refused', () {
    expect(
      () => strict.export(_CheatSource((turn) => turn.game.turn = 4)),
      _stateError('The replay differs'),
    );
  });

  test('a turn that was not played cannot be dumped nor traced', () {
    const source = ReferenceSource(strategy: 'idle', turns: 3);

    expect(() => exporter.export(source, dumpTurn: 9), _stateError('Turn 9'));
    expect(() => exporter.export(source, traceTurn: 9), _stateError('Turn 9'));
  });
}
