# presentation/ui/fight

The cards of a fight report, ported from `lib/presentation/widgets/fight/`:
the parts every report is made of. The raid and the kraken wave reports
(`../threat/`) and the monsters' fights (below) use them; the history's report
launchers use them next. Each card is a `FightReportCard`
(a `RefreshingPanel` in the theme's card, a `column` to fill in `_init` and
`refresh()` that rewrites its texts) and is complete once built.

| Card | Shows |
| --- | --- |
| `FightResultBanner(victory, turn_count, label_key)` | victory or defeat (or the text of `label_key`, such as a capture) and how many turns the fight lasted (-1 to say nothing of it) |
| `MonsterPreview(lair)` | family and difficulty, level and count, the stats of one monster (`MonsterUnitStats`) in three chips, `MonsterFamilyTraits` (the rule and what answers it, hidden for the generic monsters) |
| `FightUnitAccounting(sent, intact, wounded, dead)` | a `UnitPortrait` and the "sent / intact / wounded / dead" line of each type sent |
| `FightKillCount(fight, guardians)` | enemies killed, or guardians for an assault on a guarded place |
| `ResourceTallyCard` | a titled list of resources with an amount each, or a line saying there were none; `FightLootCard` ("+" in cyan) is the loot of a fight |
| `FightTurnList(summaries)` | one `FightTurnTile` per turn: allies' and enemies' figures, the critical hits |

## Not one to one

- The monster is a `Portrait` (initials on a tint) until step 7 renders the
  models; the weakness line carries the `flag` glyph where Flutter draws a
  crosshair.
- `ResourceTallyCard` joins `FightLootCard` and the raid's `RaidPillageCard`
  (`../threat/`), two cards that differ only by title, colour and sign.
- Flutter's `FightReportCard.line` is a card with one `Label`; here a
  card holds a `column` and `text_label()` makes the labels of its lines.
- The tests are in `tests/`, on `UiTestCase`, from the fights of
  `HistorySamples` and the real ones of `ThreatSamples`.

## The fights against the lairs

The pages and the sheet of a fight against a lair of the map
(`lib/presentation/widgets/map/monster_lair_sheet.dart`, `widgets/fight/` and
`screens/game/fight/`). None of them changes the game: they pick and ask, and
`app/game/FightController` runs the action and opens what follows.

| Component | Does |
| --- | --- |
| `MonsterLairSheet(lair, x, y)` | a `MapSheet`: the family's initials, "Family (x, y)", difficulty, level, count and stats in rows, the rule and weakness (`MonsterFamilyTraits`), "cancel" and "prepare the fight" (`prepare_requested`, told once the sheet closed) |
| `ArmySelection(title, available, boost, launch_key, confirm, header)` | a `FullPage`, generic: a header, a `UnitQuantityRow` per type in stock, the `SelectionSummaryCard` and the `ArmySelectionActions`. Launching calls `confirm(picks)`, which returns an `ActionResult`: a success ends the page with it, a refusal is told in the page (`ActionFailureTexts`) until the next pick. Cancelling or the back arrow ends it with null. The transition, kernel and base selections of lots 12 and 13 reuse it with their own title, stock, header and `confirm` |
| `SelectionSummaryCard(boost)` | the attack and defence of the units picked (`show_totals`) and the military bonus |
| `ArmySelectionSummary` | the totals, with the `UnitBoost` the fight uses (`TechEffects.unit_boost(attacking)`) |
| `ArmySelectionActions(launch_key)` | launch (off until `set_ready(true)`), cancel, and the warning of a missing admiral (`set_admiral_missing`, for the assaults) |
| `AssaultSummaryPage(title, captured_key, victory, captured, fight, sent, intact, wounded, dead)` | the report of an assault on a place the guardians hold: banner (a capture in its own words), units, guardians killed, turns; no monsters, no loot, and without a fight only the result and the units. `TransitionFightSummaryPage` (`../post/`) and `KernelFightSummaryPage` (`../kernel/`) derive from it |
| `AssaultSelections.transition(...)`, `.kernel(...)` | the `ArmySelection` of an assault: "Assault: <place>", the units of the level, `needs_admiral` (the page warns until an Admiral is picked and launches only with one), and a `plan` (lot 13) shown before the rows; `picks_changed(chosen)` lets it follow the picks |
| `FightSummaryPage(result, lair, x, y)` | the report: banner, monsters, units, kills, loot of a victory, turns, "back to the map". `HistoryReports.fight_summary(combat_entry)` (`ui/history/`) rebuilds it from the history's `CombatEntry` |

Not one to one: the Flutter selection screen pops with the result even when
the action failed (and its summary then reads a fight that is not there); here
a refusal stays in the page. The strike played on the map before the report is
step 7.
