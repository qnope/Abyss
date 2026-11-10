# domain

The game's rules, and nothing else: resources, buildings, technologies, units,
turns, the map, combat, factions. Plain typed classes that extend `RefCounted`
(or `Resource` for data they describe), complete once `_init` returns.

No `Node`, no scene tree, no rendering, input or file APIs: a rule here must
run the same in a test, on the web and on a phone.

Depends on nothing outside `domain/`.

The rules are ported from `lib/domain` to give the same game, to the last
die. A ported rule never uses `randi`, `randf`, `Array.shuffle`, `Array.sort`
or `sort_custom` with a comparator that can tie, `%` on a whole number that
can be negative, `/` between two whole numbers, `pow` nor `**`: it goes
through `DartRandom`, `DartSort`, `DartMath`, `DartBits` and `DartNum` of
[`dart/`](dart/README.md), which says what to write for each Dart
expression and what GDScript already does as Dart.

## Porting conventions

Set by the first modules ported (`resource`, `building`, `worksite`, `unit`);
every later module follows them, so that a Dart file and its port read side
by side.

**Files and names.** One Dart file, one GDScript file of the same name in
the same module folder, its `class_name` the Dart class, its first comment
the Dart path. Members take GDScript's case: `maxStorage` is `max_storage`,
a constant `MIN_ENERGY_STORAGE`, a private `_name`. A Dart file of top-level
functions or constants is a class named after the file:
`exponentialCost(base, step)` is `ExponentialCost.exponential_cost(base,
step)`. A type a module needs from one not ported yet is ported alone, in
its future folder (`fight/monster_unit_stats.gd`, which sizes the lairs of
`map`), never the whole module.

**Names Godot owns.** A Dart class named as an engine class, a built-in
type, a singleton or a class of `godot/` takes the prefix `Game`; its file
keeps the Dart name. Of the 427 names of `lib/domain`, one collides:

| Dart | GDScript | File |
| --- | --- | --- |
| `Resource` | `GameResource` | `resource/resource.gd` |

A member or a parameter named as a global function of Godot is renamed
too, a parameter with the `_` of those that fill a field: the `seed` of
`GameMap` is `map_seed`, as the `seed` of a `Random` is `initial_seed`, and
`generate(seed: 3)` is `generate(seed_)`.

**Enums.** `class_name BuildingType` holding `enum Value { HEADQUARTERS,
ALGAE_FARM, ... }`, the values **in the Dart order** so that a value is its
Dart `index`. The type is `BuildingType.Value`, in signatures and as a
dictionary key. The snapshots, journals and vectors write Dart names:
`DartEnum.name_of(BuildingType.Value, type)` gives `"algaeFarm"`,
`DartEnum.by_name(BuildingType.Value, "algaeFarm")` the value or null
(`dart/README.md`). The fields, getters and methods of a Dart enum are static
functions taking the value: `side.opponent` is `CombatSide.opponent(side)`.
The test of each enum lists its Dart names in order.

**Maps, lists, sets.** A `Map<K, V>` is a `Dictionary[K, V]` filled in the
order the Dart code fills it: that order is state. A `List<T>` is an
`Array[T]`, a `Set<T>` a `Dictionary[T, bool]` whose keys are the members.
GDScript types no collection inside another: `Map<int, Map<UnitType, Unit>>`
is `Dictionary[int, Dictionary]`, each inner map built typed and read back
into a typed variable (an untyped one is refused at run time). `map[key]`
that may be missing is `map.get(key)`; `map[key]?.level ?? 0`, which has no
GDScript spelling, is a static helper of the value's class marked "Not in
the Dart class" (`Building.level_in(buildings, type)`).

**Null.** An object may be null as in Dart. An `int?`, `bool?`, `String?` or
enum is a `Variant` holding the value or null, its type said in the comment
(`WorksiteRules.next_site_at_hq`). A nullable collection whose null means
"none" takes an empty default (`excluded` of `ConsumptionCalculator`).

**Constructors.** `_init` takes the Dart parameters by position, in the
order of the declaration, the optional ones last with their Dart defaults; a
parameter that fills a field is `name_`. `Resource(type: t, amount: 5)` is
`GameResource.new(t, 5)`. A named constructor or a factory is a static
function of the same name (`UpgradeReadiness.of(...)`). A `final` field is a
plain `var` nothing reassigns. A getter that computes is a method without
argument (`worksite.can_research()`); a `late final` computed from final
fields is a field set at the end of `_init` (`Combatant.role`).

**`copyWith`** (first met in `MapCell`): `copy_with(changes: Dictionary)`,
the fields to change by their GDScript name. A key that is there replaces
the field, even by null, which is what Dart's sentinel tells apart; an
unknown key logs an error. A field Dart copies with `field ?? this.field`
(the terrain and the content of a cell) keeps its value when given null.

**Equality.** GDScript compares objects by identity and cannot change it. A
class with `operator ==` gets `equals(other) -> bool`. Where the rules use
such objects as keys of a map or members of a set (`GridPosition`), the key
is a value Godot compares by content: a `Vector2i` for a position
(`GridPosition.key()`, `of_key`, `keys`), else the text or number the Dart
`hashCode` is made of (the code of a `TransitionBaseName`).

**Records.** A record of two whole numbers is a `Vector2i`, the first in
`x` (`MapLayout.lair_range_for`, the cells of `VolcanicKernelPlacer
.footprint`). A record with named fields is an inner class of the class
that returns it (`VolcanoFootprint.TapTarget`).

**Constants and tables.** A `static const` is a typed `const`. A const map
or list is a typed `const`, read-only as in Dart. A const map of maps is a
`Dictionary[K, Dictionary]` with a function giving one inner map typed
(`BuildingBaseCosts.of`). A table of objects or functions cannot be a
constant: a static function builds it at each call
(`ProductionFormulas.production_formulas()`). A real cache is a `static var`
with `debug_reset()`, listed in `tool/test/process_resets.gd`.

**`switch` on an enum.** GDScript checks no exhaustiveness, and a `return`
no value reaches would never be covered. Constant cases are a `const` table
keyed by the enum (`ConsumptionCalculator`); otherwise a `match` whose last
Dart case is the `return` after it, named in a comment
(`UnitStats.for_type`).

**Where Dart throws**, the port logs an error with `push_error` and returns
a value Dart never returned (`dart/README.md`).

**No Hive.** No annotation, no adapter, `RefCounted` instead of
`HiveObject`: saves come later, in `data/`. Every field of the state stays;
the fields that only keep the layout of old saves (`reference/README.md`,
"Fields left out") are dropped, and no rule may change for it.

### Tests

Each Dart test file of `test/domain/<module>/` is ported to
`<module>/tests/<same name>_test.gd`, test for test: `group('upgradeCost')`,
`test('HQ at max level 10: empty')` is
`test_upgrade_cost_hq_at_max_level_10_empty`. The first comment names the
Dart file and the tests left out, with the module each waits for (a
`Player`, an action) or why it never comes (a Hive round-trip, a widget). A
file too long for 150 lines is split by group, `<name>_<group>_test.gd`.
Tests Dart generates in a loop are one test that loops. A test the Dart file
does not have says "Not in the Dart file". `DomainSamples`
(`tool/samples/`) builds the sample bases, armies and stocks.

A rule that has vectors reads **every case** of its sections in a test that
`extends VectorTestCase`, through the GDScript twin of the call the section's
`api` names; `VectorInputs` reads what a case writes. `VectorRegistry`
(`tool/reference/`) lists each section under that test, or under
`pending: <module>`: move the sections of a module when porting it.

### Left for a later lot

Files and tests of the modules above that wait for another module:

| Dart | Waits for |
| --- | --- |
| `pearl_income_test.dart` (its two tests of the end of turn) | `turn` |
| `resource/consumption_integration_test.dart` | `game`, `turn` |
| `building_degradation_effects_test.dart` (`TurnProduction sees the degraded buildings`) | `turn` |
| `building_degradation_usage_test.dart` (actions, victory), `building_cost_discount_test.dart` (its last test) | `action`, `game` |
| `building_degradation_solo_test.dart` | `script` |
| `game/difficulty_test.dart`, `difficulty_faction_test.dart`, `difficulty_world_relief_test.dart`, `difficulty_faction_monsters_test.dart` (the tests on a wave, a turn or a new game) | `raid`, `volcano`, `turn`, `game` |
| `map/exploration_resolver.dart`, its four tests (`exploration_resolver_test.dart`, `_level_`, `_multi_`, `exploration_volcano_test.dart`) | `game` (`TechEffects.of`) |
| `map/rival_taker.dart`, its test | `game`, `faction` |
| `revealWhole` and `migrate` of `map/volcano_footprint.dart`, their three tests of `volcano_footprint_test.dart`; the last test of `reveal_area_calculator_base_test.dart` | `game` |
| `settings/language_choice.dart`, its test | none of these modules reads it: with the lot that ports the settings |
