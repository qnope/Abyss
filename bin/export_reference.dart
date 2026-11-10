// Exports reference games: a scripted game with its journal and, turn
// after turn, the digest of every section of its state, for the Godot port
// of the rules to replay and compare (see reference/README.md).
//
//   dart run bin/export_reference.dart --strategy conquest --seed 3 \
//       --difficulty hard --factions 3 --turns 120 \
//       --out reference/games/conquest-hard-3-factions.json
//   dart run bin/export_reference.dart \
//       --scenario scenarios/replays/victoire-tour-84.json --out game.json
//   dart run bin/export_reference.dart --check
//   dart run bin/export_reference.dart \
//       --reference reference/games/conquest-hard-3-factions.json \
//       --dump-turn 37 --trace-turn 36
//
// The game to play:
//   --strategy <name>    built-in strategy (see bin/simulate.dart)
//   --scenario <file>    JSON scenario or exported replay
//   --seed <n>           seed of the map and of every die (default 1)
//   --difficulty <d>     easy, normal (default) or hard
//   --factions <n|a,b>   factions drawn with the seed, or their names
//   --turns <n>          turn limit (default 60)
//   --reference <file>   or: the game of an existing reference file
//
// What to write:
//   --out <file>         the reference game
//   --dump-turn <n>      the whole canonical state at the start of turn n
//                        (or `final`), in <out>.turn-<n>.dump.json
//   --trace-turn <n>     the digests after each action of turn n, in
//                        <out>.turn-<n>.trace.json
//
// The committed set:
//   --check [folder]     plays every reference of the folder (default
//                        reference/games) again; fails, naming them, when
//                        some differ, regenerated in a temporary folder
//   --update [folder]    same, but writes the files that changed back
import 'dart:io';

import 'package:abyss/domain/reference/reference_cli.dart';

import '../tool/reference/disk_io.dart';
import '../tool/reference/sha256_hex.dart';

void main(List<String> args) {
  try {
    exitCode = ReferenceCli(digest: sha256Hex, io: diskIo()).run(args);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    exitCode = 64;
  }
}
