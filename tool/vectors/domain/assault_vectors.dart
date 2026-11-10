import 'package:abyss/domain/fight/assault/assault_chance.dart';
import 'package:abyss/domain/fight/assault/assault_rehearsals.dart';
import 'package:abyss/domain/fight/assault/assault_target.dart';
import 'package:abyss/domain/fight/unit_boost.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import '../vector_file.dart';
import '../vector_json.dart';
import 'fight_planning_cases.dart';

/// The chances the game shows before an assault on a guardian.
abstract final class AssaultSections {
  static final Map<String, VectorSection> sections = {
    'assaultChance': VectorSection(
      'c = AssaultRehearsals.chanceOf(army, target, boost): c.wins, '
          'c.rehearsals, c.rate and c.rating; harpoonists is '
          'AssaultRehearsals.harpoonistsFor(army, target, boost, '
          'maxAdded: 300), army being the escort',
      () => [
        for (final AssaultTarget target in AssaultTarget.values)
          for (final (Map<UnitType, int> army, UnitBoost boost)
              in FightPlanningCases.assaults)
            {
              'target': target,
              'army': VectorJson.pairs(army),
              'boost': [boost.atkPercent, boost.defPercent, boost.hpPercent],
              'out': _assault(army, target, boost),
            },
      ],
    ),
    'assaultRating': VectorSection(
      'AssaultChance(wins: wins, rehearsals: rehearsals): rate and rating',
      () => [
        for (final int rehearsals in const [0, 8, 20])
          for (var wins = 0; wins <= rehearsals; wins++)
            {
              'wins': wins,
              'rehearsals': rehearsals,
              'out': _chance(AssaultChance(wins: wins, rehearsals: rehearsals)),
            },
      ],
    ),
  };

  static Map<String, Object?> _assault(
    Map<UnitType, int> army,
    AssaultTarget target,
    UnitBoost boost,
  ) => {
    ..._chance(AssaultRehearsals.chanceOf(army, target, boost)),
    'harpoonists': AssaultRehearsals.harpoonistsFor(
      army,
      target,
      boost,
      maxAdded: 300,
    ),
  };

  static Map<String, Object?> _chance(AssaultChance c) => {
    'wins': c.wins,
    'rehearsals': c.rehearsals,
    'rate': c.rate,
    'rating': c.rating,
  };
}
