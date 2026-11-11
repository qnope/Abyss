# presentation/ui/kernel

The Volcanic Kernel of the map, ported from `lib/presentation/widgets/map/
volcanic_kernel_sheet.dart`, `widgets/volcano/kernel_garrison_panel.dart` and
`screens/game/fight/kernel_fight_summary_screen.dart`. Everything is read from the
domain `Game`; the sheet only tells what the player wants, `app/game/KernelController`
acts. Depends on `domain/`, `../theme`, `../l10n`, `../texts`, `../common`, `../map`,
`../unit` and `../fight` only.

| Component | Does |
| --- | --- |
| `VolcanicKernelSheet(game, captured, plan)` | a `MapSheet`: the volcano's picture and description; guarded, the `plan` (`../assault/`) and "Launch the assault"; held, the `KernelGarrisonPanel`. `attack_requested`, `garrison_requested` and `withdraw_requested` come after the sheet closed |
| `KernelGarrisonPanel(player, guided)` | the kernel's level, the magma rampart, the garrison (`UnitCountPanel`), the units waiting outside it on the volcano level, the next kraken wave, the levels lost, and the buttons to garrison (inside the guide's `GuideHalo` when `guided`) and withdraw (off while nobody is in) |
| `KernelFightSummaryPage(result, x, y)` | an `AssaultSummaryPage` (`../fight/`): "Assault: Volcanic Kernel", "kernel captured" |

The army to assault with is `AssaultSelections.kernel` (`../fight/`); the garrison is
picked with `UnitPickerDialog` (`../unit/`); the victory of a kernel at level 10 is the
session's (`GameActions.victory_reached`, the screen of `../game_over/`).

## Not one to one

- The kernel's picture is a `Portrait` until step 7.
- The garrison's news (its size, a refusal) is a `MessageDialog`, not a snack bar.
- The guide's halo reads `GuideAdvisor` itself (`target.garrison`); the ring on
  the volcano's cell of the map is `app/game/GuideController`'s.
- The kernel a rival holds opens `../post/RivalPostSheet` (no post): `app/game/FactionController` runs the attack.
