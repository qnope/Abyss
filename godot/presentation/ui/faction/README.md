# presentation/ui/faction

The rival factions, ported from `lib/presentation/widgets/faction/*`,
`widgets/turn/{attack_turn_section,attack_report_lines}.dart` and the ranking of
`screens/`. Everything is read from the domain `Game`; the widgets only tell what the
player wants, `app/game/FactionController` acts. Depends on `domain/`, `../theme`,
`../l10n`, `../texts`, `../common`, `../map`, `../unit`, `../fight`, `../assault` and
`../turn` only.

| Component | Does |
| --- | --- |
| `FactionEmblem(personality, size)` | a `UiIcon` of the emblem of a personality |
| `FactionIdentity(faction)` | the emblem, the name in the colour of the faction and its origin (`LoreText`) |
| `BaseIntelReport(intel, turn)` | what a Scout reported: the rampart, the army, the stocks, and how many turns it still holds (or that it is stale) |
| `FactionBaseSheet(faction, hq_level, refusal, intel, turn, spy_refusal)` | a `MapSheet`: the identity, the headquarters level, the report or that there is none, "Spy" and "Attack" (off with the `refusal` told under it). `spy_requested` and `attack_requested` come after the sheet closed |
| `FactionStandingTile(standing)` / `FactionRankingSheet(standings)` | a line of the ranking and the `BottomSheet` that lists them (opened from the settings: `../settings/SettingsLinks`) |
| `AttackReportLines(report)` | one attack of a faction on the human: what it hit and how it ended, then what was lost with it |
| `AttackTurnSection(reports)` | the attacks in the end-of-turn summary, each with "See the report", which opens a `BaseAssaultSummaryPage` over the summary (`ModalLayer.enclosing`) |
| `AttackSections.of(result)` | the section of `SummarySections`, empty without attack (a static builder here, since a node that builds itself in a static function leaks its script) |

## Not one to one

- The base sheet has no title label: the identity is the title (`MapSheet` accepts a null title).
- The attacks of the human on a faction have a plan only for posts and the kernel
  (`../assault/`); a base assault has none, as in Flutter.
- `TurnWarnings` does not warn of the attacks of the factions: Flutter does not either.
