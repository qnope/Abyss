import 'domain/building_vectors.dart';
import 'domain/event_vectors.dart';
import 'domain/faction_vectors.dart';
import 'domain/fight_aftermath_vectors.dart';
import 'domain/fight_engine_vectors.dart';
import 'domain/fight_planning_vectors.dart';
import 'domain/fight_rule_vectors.dart';
import 'domain/map_rule_vectors.dart';
import 'domain/map_vectors.dart';
import 'domain/raid_vectors.dart';
import 'domain/resource_vectors.dart';
import 'domain/tech_vectors.dart';
import 'domain/unit_vectors.dart';
import 'language/math_vectors.dart';
import 'language/random_vectors.dart';
import 'language/shuffle_vectors.dart';
import 'language/sort_vectors.dart';
import 'vector_file.dart';

/// Every vector file of `reference/vectors/`.
abstract final class VectorCatalog {
  /// Where the files are committed, from the root of the repository.
  static const String folder = 'reference/vectors';

  /// What Dart itself does, that the port writes again: `DartRandom`,
  /// `DartSort` and `DartMath`.
  static final List<VectorFile> language = <VectorFile>[
    RandomVectors.file,
    ShuffleVectors.file,
    SortVectors.file,
    MathVectors.file,
  ];

  /// What the pure calculators of `lib/domain` answer.
  static final List<VectorFile> domain = <VectorFile>[
    BuildingVectors.file,
    ResourceVectors.file,
    UnitVectors.file,
    TechVectors.file,
    FightRuleVectors.file,
    FightEngineVectors.file,
    FightAftermathVectors.file,
    FightPlanningVectors.file,
    MapRuleVectors.file,
    MapVectors.file,
    EventVectors.file,
    RaidVectors.file,
    FactionVectors.file,
  ];

  static final List<VectorFile> all = <VectorFile>[...language, ...domain];
}
