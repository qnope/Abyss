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
| `script/action_spec.dart` (a typedef: an `ActionSpec` is a `Callable` taking a `DartRandom` and giving an `Action`) | `script/action_codec.dart`, its only reader |
| `action/end_turn_action.dart`, `end_turn_action_result.dart`, their tests, the last test of `worksite_limits_test.dart` (the end of a turn frees the worksites) | `turn` (`PlayerTurnResolver`, the turns of the factions) |
| `held_attack_report/held_kernel_report_test.dart`, `held_post_report_test.dart`; `announce_attack/announced_attack_report_test.dart`, `announced_attack_resolve_test.dart` (they end the turn; `held_attack_reports_test.gd` and `announced_attack_resolver_test.gd` call the two steps meanwhile) | `turn` (`EndTurnAction`, `TurnResult.attacks`) |
| `volcano/wave_held_back_turn_test.dart` | `turn` (`TurnResolver`) |
| `ReplayJournal.record`, the three tests of `replay_journal_test.dart` (its Hive round-trip never comes); the call of `ActionExecutor` into it; the last test of `choose_event_action_test.dart` (the choice is written in the replay journal) | `action` (`ActionEncoder`) |
| `game/save_outcome.dart`, `save_sections.dart`, `save_summary.dart`, their tests; `game_last_played_test.dart` (the dates `Game` leaves out) | `data` (the saves) |
| `game_factory_factions_test.dart` (the human exploring) | `turn` (`EndTurnAction`) |
| `pearl_income_test.dart` (its two tests of the end of turn) | `turn` |
| `resource/consumption_integration_test.dart` | `turn` |
| `building_degradation_effects_test.dart` (`TurnProduction sees the degraded buildings`) | `turn` |
| `building_degradation_solo_test.dart` | `script` |
| `difficulty_faction_test.dart` (its two tests of the end of a turn) | `turn` |
| `history/entries/turn_end_entry_factory.dart`, the group `TurnEndEntryFactory` of `turn_end_entry_test.dart`, the group `TurnResult` of `turn_result_test.dart` | `turn` (`TurnResult`, which holds the reports of the raids, the volcano and the factions) |
| `leviathan/leviathan_turn_test.dart` (the guardians through `EndTurnAction` and `TurnResult`) | `turn` |
| `objective/guide/guide_alerts.dart` | `faction` (`UndefendedPosts`, which reads `action`'s `PostTakeover`) |
| `objective/guide/guide_campaign.dart`, `guide_campaign_alerts_test.dart`, `guide_campaign_assault_test.dart`, `guide_campaign_descent_test.dart`, `guide_campaign_steps_test.dart` | `GuideAlerts` above |
| `objective/guide/guide_advisor.dart`, `guide_advisor_test.dart`, `guide_advisor_context_test.dart`, `guide_advisor_raid_test.dart` (the guide's messages, targets, raid and map are held by tests of their own); the last test of `guide_leviathan_test.dart` (the tutorial off: the others read `GuideLeviathan` itself) | `GuideCampaign` above |
| `producingPlayer` and `choiceEvents` of `event_test_helper.dart` | the tests that use them: `turn`, `script` |
| `settings/language_choice.dart`, its test | none of these modules reads it: with the lot that ports the settings |
