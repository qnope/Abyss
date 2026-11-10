import 'dart:io';

import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/reference/reference_source.dart';

/// Reads a scenario from the repository; the tests run from its root.
String readScenario(String path) => File(path).readAsStringSync();

/// Games short enough for a test, of every kind a reference game is made:
/// a strategy alone, against factions, a scenario that hands turns to a
/// strategy, and a game exported from the app.
const Map<String, ReferenceSource> sources = <String, ReferenceSource>{
  'economy alone': ReferenceSource(strategy: 'economy', seed: 1, turns: 30),
  'conquest against two factions': ReferenceSource(
    strategy: 'conquest',
    seed: 3,
    difficulty: Difficulty.hard,
    factions: <FactionPersonality>[
      FactionPersonality.murenaHorde,
      FactionPersonality.pearlOrder,
    ],
    turns: 35,
  ),
  'a scenario': ReferenceSource(
    scenario: 'scenarios/rush-caserne.json',
    seed: 5,
    difficulty: Difficulty.easy,
    turns: 25,
  ),
  'an exported game': ReferenceSource(
    scenario: 'scenarios/replays/victoire-tour-85.json',
  ),
};
