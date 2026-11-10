# Vectors

Inputs and what the Dart code answers to them, one JSON file per subject.
A module of `lib/domain` ported to GDScript reads the file of its subject,
calls its own code with each input and must find the same output, to the
last bit: that is what "the same game" means for the port.

The Dart VM is the reference (`dart run`, `flutter test`), not the web
build: dart2js has another `Random` and no 64-bit whole numbers.

## Regenerating

```sh
dart run bin/export_vectors.dart            # writes reference/vectors/*.json
dart run bin/export_vectors.dart --check    # exits 1 naming the stale files
dart run bin/export_vectors.dart --out dir  # writes elsewhere
```

`test/tool/vectors/vector_catalog_test.dart` fails when a committed file is
stale, so `tool/test.sh` covers it. Never edit a `.json` by hand.

The generators live in `tool/vectors/`, not in `lib/`: they are tooling,
they must not ship in the app nor be reachable from the rules, and `tool/`
already holds Dart libraries tested from `test/tool/`. `bin/` only parses
the arguments. `tool/vectors/language/` covers what Dart itself does,
`tool/vectors/domain/` what the rules do, each through its public API.

## Format

```json
{"name": "units",
 "api": {"boost": "UnitBoost(atkPercent: percent).atk(stat); ..."},
 "sections": {"boost": [{"percent": 10, "stats": [5], "out": [6]}]}}
```

- `api` gives, per section, the Dart call behind every case; a case holds
  named inputs and `out` (a few sections add other named outputs, which
  their `api` describes). One case per line.
- Only objects, lists, strings, whole numbers, booleans and null.
- **A double is never a JSON number** but `"d:"` and the 16 lowercase hex
  digits of its IEEE-754 bits, sign first (`"d:3ff8000000000000"` is 1.5).
  Every NaN is `d:7ff8000000000000`.
- A whole number beyond ±2^53 is `"i:"` and its decimal digits: Godot's
  `JSON` reads every number as a float and would round it.
- An enum is its name. Keys are sorted, so a JSON object carries **no
  order**: where the order of a Dart map matters (an army, whose entries
  set the order of the combatants) the case writes a list of
  `[key, value]` pairs.
- A side of a fight is a list of runs `[typeKey, side, maxHp, atk, def,
  isBoss, count]`: `count` identical fresh `Combatant`, in order. One
  combatant alone is `[typeKey, side, maxHp, atk, def, currentHp, isBoss]`.
- A generated map is `seed, width, height, baseX, baseY, bases` and
  `cells`: `[index, content, lair, transitionBase, passageName]` for each
  cell that holds anything, `index = y * width + x`, `lair` as
  `[difficulty, family, unitCount]`, `transitionBase` as `[type, name]`,
  trailing nulls left out. The cells left out are plain `empty` cells.

## Files

Language, to port first as `DartRandom`, `DartSort` and `DartMath`:

| File | Sections | Dart |
| --- | --- | --- |
| `dart_random.json` | `nextInt`, `nextDouble`, `nextBool`, `mixed`, `afterMany`, `refused`, `seededRandom` | `Random(seed)` for 35 seeds (negative, beyond 2^32, the one seed that mixes to 0) and 37 bounds; `SeededRandom` |
| `dart_shuffle.json` | `shuffle`, `twice` | `List.shuffle(random)`, lengths 0 to 400 |
| `dart_sort.json` | `sort`, `natural` | `List.sort` with ties, lengths 0 to 500, with the number of comparisons |
| `dart_math.json` | `intDivision`, `divisionByZero`, `bits`, `abs`, `rounding`, `notFinite`, `quotient`, `pow`, `clamp`, `minMax`, `literals` | `~/`, `%`, `remainder`, wrapping, shifts, `round`/`floor`/`ceil`/`truncate`/`toInt`, `int / int`, `pow`, `clamp`, `min`/`max`, and every double literal of `lib/domain` |

Rules:

| File | Sections | Dart |
| --- | --- | --- |
| `buildings.json` | `exponentialCost`, `upgradeCost`, `limits`, `degradation`, `rampart`, `worksites` | `exponentialCost`, `BuildingCostCalculator`, `BuildingDegradation`, `BuildingDeactivator`, `CoralCitadelRampart`, `WorksiteRules` |
| `resources.json` | `buildingProduction`, `production`, `energyConsumption`, `totalConsumption`, `startingStocks`, `storage`, `credit` | `productionFormulas`, `ProductionCalculator`, `Difficulty.scaleProduction`, `ConsumptionCalculator`, `PlayerDefaults`, `Resource`, `ResourceCredit` |
| `units.json` | `units`, `boost`, `maxRecruitable`, `hungerLosses`, `hungerLossesAllLevels` | `UnitStats`, `CombatRole`, `UnitCostCalculator`, `UnitBoost`, `UnitLossCalculator` |
| `tech.json` | `unlockCost`, `researchCost`, `branchState`, `effects` | `TechCostCalculator`, `TechBranchState`, `TechEffects` |
| `fight_rules.json` | `damage`, `attackDamage`, `monsters`, `monsterLevels`, `guardians`, `magmaRampart`, `leviathan` | `DamageCalculator`, `AttackDamage`, `MonsterRules`, `MonsterUnitStats`, `MonsterFamily`, `GuardianFactory`, `MagmaRampart`, `LeviathanForce` |
| `fight_engine.json` | `resolve`, `critChance`, `twoFights` | `FightEngine.resolve`: 24 fights times 3 seeds, turn by turn |
| `fight_aftermath.json` | `woundedProbability`, `pctLost`, `casualties`, `lairLoot`, `treasureLoot` | `CasualtyCalculator`, `FightMonsterHelpers.computePctLost`, `LootCalculator`, `TreasureLoot` |
| `fight_planning.json` | `strength`, `rehearsal`, `planner`, `assaultChance`, `assaultRating` | `ArmyRehearsal`, `ArmyPlanner`, `AssaultRehearsals`, `AssaultChance` |
| `map_rules.json` | `layout`, `lairFamily`, `lair`, `startingBases`, `reveal`, `posts`, `volcano` | `MapLayout`, `LairBuilder`, `StartingBasePlacer`, `RevealAreaCalculator`, `TransitionBaseName`, `TransitionBase`, `VolcanicKernelPlacer` |
| `maps.json` | `world`, `level` | `WorldGenerator.generate` (14 worlds, 3 levels, maps of 20, 26 and 32) and `MapGenerator.generate` with reserved passages, cell by cell |
| `events.json` | `drawTurns`, `pick`, `survivors`, `production` | `EventDrawer`, `SurvivorsEffect`, `EventProduction` |
| `raids.json` | `wave`, `everyWave`, `defenceStrength`, `loot`, `pillage`, `krakens`, `monsterPercent`, `upgradeNoise` | `RaidWaveFactory`, `DefenceStrength`, `RaidSpoils`, `VolcanoWaveFactory`, `Difficulty`, `NoiseRules` |
| `factions.json` | `draw`, `traits`, `slots`, `siege`, `siegesPerTurn`, `explorationBias` | `FactionCatalogue`, `FactionTraits`, `FactionWar`, `KernelSiege`, `FactionExploration` |

In `tech.json`, the keys of an `effects` output are the getters of
`TechEffects`: `atk` is `atkPercent()`, `atkAttacking` is
`atkPercent(attacking: true)`, `def` is `defPercent()`, `defBase` is
`defPercent(defendingBase: true)`, `hp` is `hpPercent`, `production` is
`productionPercent(type)` per resource, `upgradeDiscount` is
`upgradeDiscountPercent`, `muffle` is `muffle(noise)` for noise 0, 1, 3
and 7, `boostLoot` is `boostLoot({algae: 333, coral: 1, pearl: 3})`;
`pillageRate`, `revealSide`, `lootPercent` and `raidWarningTurns` bear the
name of their getter.

Not covered: what needs a whole `Game` (the turn resolvers, the actions,
exploration, the caravan, predators, wreck sites and storm effects,
`PearlIncome`, `AssaultPlan.of`, `AssaultTarget.at`, `GameFactory`, the
faction scripts): the whole-game references of `reference/games/` are for
them. `FactionTurns._seedOf` is private (its formula is below),
`SeededRandom.fresh()` is not deterministic, and `toStringAsFixed` is only
used by reports.

## `Random(seed)`

From `sdk/lib/_internal/vm/lib/math_patch.dart` (Dart 3.13), written again
as `test/tool/vectors/spec/dart_random_spec.dart`, which the tests hold
against every vector. One 64-bit state; every sum and product wraps to 64
bits and `>>>` fills with zeros.

```
seed:    n = seed
         n = ~n + (n << 21);  n ^= n >>> 24;  n *= 265;  n ^= n >>> 14
         n *= 21;             n ^= n >>> 28;  n += n << 31
         if n == 0: n = 0x5a17
         state = n, then advance 4 times
advance: state = 0xffffda61 * (state & 0xffffffff) + (state >>> 32)
nextInt(max): RangeError unless 1 <= max <= 2^32
         max a power of two: advance; return state & 0xffffffff & (max - 1)
         else: do { advance; low = state & 0xffffffff; r = low % max }
               while low - r + max > 2^32;  return r
nextDouble(): (nextInt(2^26) * 2^27 + nextInt(2^27)) / 2^53
nextBool():   nextInt(2) == 0
```

`List.shuffle(random)` (`sdk/lib/collection/list.dart`) goes down from the
end: `n = length; while n > 1 { pos = random.nextInt(n); n -= 1; swap
list[n] and list[pos] }`.

In GDScript: whole numbers wrap as in Dart, `>>` keeps the sign and there
is no `>>>` (`(x >> 32) & 0xffffffff` does it here, a mask sized to the
shift in general).

## `List.sort`

From `sdk/lib/internal/sort.dart`, written again statement for statement
as `test/tool/vectors/spec/dart_sort_spec.dart`: the tests hold it against
every vector, with the same number of comparisons.

- A range of **up to 33 elements** (`right - left <= 32`) is sorted by
  insertion, which is stable: equal elements keep their order.
- A longer one by a dual-pivot quicksort, **not stable**: five samples at
  `left + sixth`, `mid - sixth`, `mid`, `mid + sixth`, `right - sixth`
  (`sixth = length ~/ 6`, `mid = (left + right) ~/ 2`) go through a network
  of nine compare-and-swaps, the second and fourth are the pivots; equal
  pivots give a three-way partition around one value, different ones a
  partition in `< pivot1 | between | > pivot2`; the left and right parts
  are sorted first, then the middle, the elements equal to a pivot taken
  out of it when it covers more than two thirds of the range. The spec
  keeps an oddity of the SDK in that last loop (a branch that never runs).

A port must sort with the same algorithm wherever a comparator can tie
on more than 33 elements; `Array.sort_custom` of Godot is not stable
either, and not in the same way.

### Every `.sort(` of `lib/domain`

| File | Where | Sorted by | Ties |
| --- | --- | --- | --- |
| `event/effects/wreck_sites.dart` | `WreckSites` | cell indices | none: distinct |
| `game/save_sections.dart` | `_latestFirst` | `lastPlayedAt`, latest first | possible, and more than 33 saves would not be stable; menu only |
| `objective/tip/tip_catalog.dart` | `TipCatalog.all` | index of the id | none: unique ids |
| `objective/guide/guide_map.dart` | nearest target | distance, then y, then x | none: total order |
| `replay/replay_export.dart` | turns of the actions | turn numbers | none: map keys |
| `replay/replay_export.dart` | turns of the seeds | turn numbers | none: map keys |
| `faction/faction_standing.dart` | ranking | score, then playing order | none: total order |
| `faction/undefended_posts.dart` | `UndefendedPosts.of` | `targetLevel` | **yes**: posts of one level keep the order of the levels then of the grid (at most 17 posts, so stable) |
| `faction/faction_base_targets.dart` | known players | the human first on a grudge, then Chebyshev distance | **yes**: equally far players keep the order of `game.players` (at most 10, so stable) |
| `faction/faction_base_targets.dart` | targets | the human first on a grudge, strength, then player id | none: total order (`String.compareTo`, by UTF-16 code unit) |
| `faction/faction_post_war.dart` | posts to take | strength, level, y, x | none: total order |
| `script/variant/plan_script.dart` | turns of a plan | turn numbers | none: map keys |
| `script/variant/plan_script.dart` | steps due | rank | none: unique ranks |
| `script/faction_tally.dart` | `factionIds` | ids | none: map keys |
| `reference/canonical_writer.dart` | keys of a map | UTF-16 code units | none: map keys; not a rule, the snapshot's format |
| `reference/snapshot_sections.dart` | section names | names | none: distinct; not a rule |

No sort of the rules can tie beyond 33 elements today; the two that tie
rely on the insertion sort being stable.

## What else can make the port diverge

Checked against Godot 4.7.2 on x86-64 where it says "GDScript".

- **`%`**: Dart's is never negative (`-7 % 3 == 2`, `-7 % -3 == 2`).
  GDScript's `%` gives -1, and `posmod(-7, -3)` gives -1 too: only
  `posmod` with a positive divisor matches. `~/` truncates in both.
- **`/`**: `int / int` is a double in Dart (`7 / 2 == 3.5`) and a whole
  division in GDScript. The rules count on it: `(count * k / 20).ceil()`,
  `(stat * (100 + percent) / 100).round()`.
- **`round()`** rounds a half away from zero in both (`roundi`). `floor`,
  `ceil`, `toInt` of a NaN or an infinity throw in Dart.
- **`pow(1.6, step)`** goes through the C library, whose last bit
  changes from one machine to another: the vectors hold no such bit
  (`pow` keeps to results a double holds exactly), only the costs, which
  no last bit can change. A port can do without `pow`: `exponentialCost`
  equals `(2 * base * 8^step + 5^step) ~/ (2 * 5^step)` on every case
  (tested), 1.6 being 8/5 and a half never being reached. `pow` is the
  only such function of `lib/domain`: no `exp`, `log`, `sin`, `sqrt`.
- **Double literals** must parse to the same bits (`literals`): 0.85, 1.6,
  0.225, `1 / 3` did. `+`, `-`, `*`, `/` are exact IEEE operations on
  both sides.
- **`min`/`max`/`clamp`** return one of their operands: `max(1, 1.0)` is
  the int 1 in both, and stays an int in what follows.
- **Shifts**: `1 << 64` is 0 in Dart, 1 in GDScript on x86.
- **JSON**: Godot reads every number as a float; a whole number is exact
  up to 2^53 only, hence `i:`.
- **Order of maps and sets**: a Dart `Map` or `Set` literal iterates in
  insertion order, and the rules count on it: the entries of an army set
  the order of the combatants, `MonsterLair.groups`, the edge cells of
  `StartingBasePlacer`, `game.players`. GDScript `Dictionary` keeps
  insertion order too; nothing may go through a sorted or hashed copy.
- **One generator, one order of draws**: `FightEngine` draws the turn
  order, the targets and the crits from the same `Random`, a rehearsal
  plays its fights one after the other on one generator (`twoFights`),
  `EventDrawer.pick` draws nothing when no event is allowed (`next`
  tells), and a map trims its lairs after they consumed their dice.
- **Seeds derived by the rules**: levels 2 and 3 of a world get
  `Random(seed + level).nextInt(0x7FFFFFFF)` (so level 3 of world 0 and
  level 2 of world 1 draw the same seed); a rehearsal seeds with 17, then `seed * 31 + count`
  for each `UnitType`, `& 0x7FFFFFFF`; a lair's family with
  `(seed * 7919 + cellIndex) & 0x7FFFFFFF`; a faction's turn with
  `(mapSeed * 31 + turn * 1009 + index * 7919) & 0x7FFFFFFF`; the
  factions of a game with `seed ^ 0x5FAC7`. The products wrap before the
  mask.
- **Stale fields**: `MapCell.copyWith` keeps the lair or the post a cell
  was given when its content changes, so about 36 cells of a map hold a
  lair under an `empty` content; `maps.json` writes them, a port must
  keep them (or prove nothing reads them).
- **`r.wins(n, needed: k)`** stops as soon as the answer is known: its
  count only tells whether `k` is reached (`winsNeeding`).
- **`double.compareTo`** (strengths) puts -0.0 before 0.0 and NaN last,
  and a side with nothing to hit has an infinite strength.
- **Memo caches**: `AssaultRehearsals` remembers its answers in static
  caches; they hold pure results, but a port that adds one must reset it
  between test files (`process_resets.gd`).
