# presentation/ui/fight

The cards of a fight report, ported from `lib/presentation/widgets/fight/`:
the parts every report is made of. The raid and the kraken wave reports
(`../threat/`) are the first to use them; the lot of the monsters' fights and
the history's report launchers use them next. Each card is a `FightReportCard`
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
