import 'dart:io';

import '../game_script.dart';
import 'plan_script.dart';
import 'replay_variant.dart';

/// Human plans the raids are calibrated on, each played as a few nearby
/// strategies, by the name the command line uses.
///
/// A plan is an exported replay kept in `scenarios/replays/`; it is read
/// from the working directory, so the names work from the repository
/// root (simulator and tests). Add a winning replay there and a line to
/// [_plans] to calibrate on it too.
abstract final class PlanLibrary {
  static const String folder = 'scenarios/replays';

  /// Plans by short name, with their replay file.
  static const Map<String, String> _plans = <String, String>{
    'plan85': 'victoire-tour-85.json',
  };

  /// What each strategy of a plan changes from it. Every one rolls new
  /// dice per seed and defends the announced raids, unless it says not.
  static const Map<String, ReplayVariant> _variants = <String, ReplayVariant>{
    '': ReplayVariant(sameDice: false, defends: true),
    '-newmap': ReplayVariant(sameMap: false, sameDice: false, defends: true),
    '-nodefence': ReplayVariant(sameDice: false),
    '-army120': ReplayVariant(sameDice: false, defends: true, army: 1.2),
    '-army90': ReplayVariant(sameDice: false, defends: true, army: 0.9),
    '-late': ReplayVariant(sameDice: false, defends: true, jitter: 2),
    '-slow': ReplayVariant(sameDice: false, defends: true, stretch: 1.1),
  };

  static Map<String, GameScript Function()> get builders =>
      <String, GameScript Function()>{
        for (final MapEntry<String, String> plan in _plans.entries)
          for (final MapEntry<String, ReplayVariant> v in _variants.entries)
            '${plan.key}${v.key}': () => PlanScript.fromReplay(
                  File('$folder/${plan.value}').readAsStringSync(),
                  v.value,
                  name: '${plan.key}${v.key}',
                ),
      };
}
