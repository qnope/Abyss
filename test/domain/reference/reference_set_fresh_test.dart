import 'package:abyss/domain/reference/reference_exporter.dart';
import 'package:abyss/domain/reference/reference_set.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tool/reference/sha256_hex.dart';
import 'committed_games.dart';
import 'reference_sources.dart';

/// The whole set is checked by `bin/export_reference.dart --check`, in
/// under a minute; the tests play its shortest games again, to tell at
/// once that a change of the rules left the committed files behind.
void main() {
  const ReferenceSet set = ReferenceSet(
    ReferenceExporter(digest: sha256Hex, read: readScenario),
  );
  final List<CommittedGame> shortest =
      committedGames()..sort((a, b) => a.turn.compareTo(b.turn));

  for (final CommittedGame game in shortest.take(4)) {
    test('${game.name} plays the same again', () {
      expect(
        set.regenerate(game.text) == game.text,
        isTrue,
        reason:
            'reference/games/${game.name}.json is not the game the rules '
            'play today. If the rules changed on purpose, run '
            '`dart run bin/export_reference.dart --update` and port the '
            'change to godot/domain.',
      );
    });
  }
}
