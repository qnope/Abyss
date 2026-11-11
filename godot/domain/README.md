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
`GameMap` is `map_seed`, as the `seed` of a `Random` is `initial_seed` and
the `seed` of an `AnnouncedAttack` its `fight_seed`, and `generate(seed: 3)`
is `generate(seed_)`.

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
function of the same name (`UpgradeReadiness.of(...)`); where named
constructors share their names with fields, which GDScript cannot, they
all take the prefix `for_` (`GuideTarget.for_building(type)`,
`for_end_turn()`). A `final` field is a
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

**Functions and second types** (first met in `fight`). A field or a
parameter of a function type (`List<Combatant> Function()`) is a
`Callable`, a nullable one an invalid `Callable()` for null; a tear-off
such as `target.guardians` is a static function bound to its value
(`AssaultTarget.guardians_of`). A second top-level type of a Dart file
takes a file of its own, named after it, whose first comment names the
Dart file (`fight/assault/assault_rating.gd`).

**Class hierarchies** (first met in `history` and `event`). A sealed
base whose subclasses back its getters with fields holds those fields
itself, set by the `super(...)` of each subclass (`HistoryEntry`). An
abstract class whose hooks do nothing until overridden is a plain base
class with those empty hooks, their unused parameters prefixed `_`, and
each subclass overrides the ones it needs (`EventEffect`); a `const`
instance of a subclass is a `new` one. An abstract member without a body
is an `@abstract func` of an `@abstract` class (`ObjectiveGoal`), which
leaves no line for the coverage to miss. Another operator than `==` is a
method named after it: `a + b` is `a.plus(b)` (`ObjectiveProgress`).

**Abstract classes** (first met in `action`). An abstract Dart class
whose members have no body is an `@abstract` class, those members `@abstract
func`s, an abstract getter one without argument (`Action.type()`); a test
extends it with an inner class. A result of a subclass passes its reason
up, `ActionResult.new(reason)`, null a success. GDScript holds a static
function to the signature of the one of the base it hides: the `success`
of a subclass takes a default for every parameter, as
`ActionResult.success()` takes none (`FightMonsterResult.success`).

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
"Fields left out") are dropped, and no rule may change for it. What only
reads an old Hive save is not ported (`VolcanoFootprint.migrate`).

**State** (first met in `Game`, `Player` and what they hold). The rules
change these objects in place: each field is a plain `var`, a map or a
list is the very one the rules fill. A constructor parameter Dart makes
nullable to fall back on a default takes `null` when its default holds
something (`Player.new(name)` builds the stocks of `PlayerDefaults`, a new
object each time), else a typed empty default, which GDScript builds anew at
each call. A field `null` only in an old save (`savedFallen`, `savedIntel`,
`savedDifficulty`, `savedFactions`) keeps its Dart name and holds the value
Dart reads for that null (`false`, empty, `NORMAL`): no Godot save is an
old one; its getter stays a method (`has_fallen()`, `intel()`,
`difficulty()`). A pure helper that would take a class over 150 lines goes
to a class marked "Not in the Dart class" (`PlayerHoldings`). An extension
of a class is a class of static functions taking the extended object first
(`GameUpgradeReadiness.upgrade_readiness_of(game, player, type)`).

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
| The last test of `tutorial_strategy_test.dart` (`ScriptLibrary`) | the runners of `script` |
| The second test of `script_player_helpers_test.dart` (`ScriptMilestones`) | the runners of `script` |
| `faction_replay_test.dart` but its last test (`ReplayExport`, `ScenarioParser`, `ScriptRunner`, `TimelineScript`, `GameScript.factionsPlay`) | `replay_export.dart` and the runners of `script` |
| `faction_attack_play_test.dart`: games of 100 turns (`playFactionGame`, `playIdleFactionGame`), one replayed through `ScriptRunner` | a slower tier of tests, and the runners of `script` |
| The test of 60 turns of `faction_play_test.dart` (3 and 10 factions), `faction_research_play_test.dart` (40 turns of 3 factions, 7 s here), `faction_race_test.dart` (60 games of 200 turns): whole games too long for the suite | a slower tier of tests, with `playIdleFactionGame` and `faction_race.dart` |
| `script/strategies_test.dart` (whole games through `ScriptRunner` and `BatchRunner`) | the runners of `script` |
| `game/save_outcome.dart`, `save_sections.dart`, `save_summary.dart`, their tests; `game_last_played_test.dart` (the dates `Game` leaves out) | `data` (the saves) |
| `building_degradation_solo_test.dart` | `script` |
| `choiceEvents` of `event_test_helper.dart` (no test of `domain` reads it; `producingPlayer` is `EventSamples.producing_player`) | the tests of the presentation that use it |
| `settings/language_choice.dart`, its test | none of these modules reads it: with the lot that ports the settings |
| The export of the reference games (`bin/export_reference.dart`): `reference/reference_exporter.dart`, `reference_cli`, `reference_arguments`, `reference_io`, `reference_layout`, `reference_recorder`, `reference_set`, `reference_source`, `reference_milestones`, `reference_trace`, `seeded_script`, `game_capture`, `reference_game` (the writer of a file; `CommittedGame` and `ReferenceReplay` of `tool/reference/` read one and replay it); their tests, the group ReferenceLayout of `digest_rows_test.dart`, the list of the games of `reference_readme_test.dart` | an exporter on the Godot side, if one is ever needed: Godot replays what Dart writes |
| The replay of the games of `reference/` whose journal holds moves (`ReferenceReplay` takes their decoder) | the codec of the actions (`script/action_codec.dart`) |
| The section `journal` of a game played, compared with Dart's at its start only (`GameSnapshotDigests`, the replay of `idle-normal` in `reference_replay_test.gd`) | `ReplayJournal.record` (`action`) |
