# presentation/ui/assault

The plan of an assault and the report of an assault on a base, ported from
`lib/presentation/widgets/assault/*` and `screens/game/fight/base_assault_*`. Everything is
read from the domain (`AssaultPlan`, `AssaultChance`, `BaseAssaultEntry`); `app/game` acts.
Depends on `domain/`, `../theme`, `../l10n`, `../texts`, `../common`, `../unit` and
`../fight` only.

| Component | Does |
| --- | --- |
| `AssaultCheckRow(...)` | one check of the plan: a glyph and its colour (`OK`, `WARNING`, `MISSING`) and a line |
| `AssaultChanceGauge` | the chance of winning, a `ProgressBar` of the variation (`CHANCE_HIGH`, `_RISKY`, `_LOW` of `AbyssInputTheme`) and its percent |
| `AssaultPlanPanel(plan, level)` | the Admiral, the units that cover the target, the army, the next level (not for the kernel), the gauge and the advice. `show_plan(plan)` redraws it |
| `AssaultPlans` | builds the plan of a target (`plan_at`), the panel of a sheet (`sheet_panel`) and of a selection (`selection_panel`), and makes the panel follow the picks of an `ArmySelection` (`track`) |
| `AssaultLineCard(sources)` / `AssaultDamageCard` / `AssaultKernelCard` | a `FightReportCard` of lines (the base damaged, the kernel level lost) |
| `BaseAssaultSummaryPage(entry)` | an `AssaultSummaryPage` of an assault on a base, a post or a kernel of a faction, from either side (the human attacking, or defending in the history) |

## Not one to one

- The plan follows the picks through `ArmySelection.picks_changed`, with static callables.
- `BaseAssaultSummaryPage` overrides the hooks of `AssaultSummaryPage` (`_lead`, `_kill_count`,
  `_details`) rather than copying it.
