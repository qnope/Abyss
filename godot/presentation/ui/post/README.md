# presentation/ui/post

The Faille and the Cheminée of the map, ported from `lib/presentation/widgets/map/
{transition_base_sheet,transition_base_captured_section,transition_base_uncaptured_section,
rival_post_sheet,post_defence_panel}.dart`, `screens/game/descent_dialog.dart` and
`screens/game/fight/transition_*`. Everything is read from the domain `Game`; the
sheets only tell what the player wants, `app/game/PostController` acts. Depends on
`domain/`, `../theme`, `../l10n`, `../texts`, `../common`, `../map` (`MapSheet`,
`SheetSection`, `SheetInfoRow`, `PassagePicture`), `../unit` and `../fight` only.

| Component | Does |
| --- | --- |
| `TransitionBaseSheet(game, base, plan)` | a `MapSheet`: the picture lit by who holds the post (`PostPicture`), its name, its kind, then the uncaptured or the captured section. `assault_requested` and `descend_requested` come after the sheet closed |
| `TransitionBaseUncapturedSection(base, plan)` | difficulty `n/5`, income once taken, "neutral, guardians present", the `plan` of the assault (`../assault/`) and "Assault" |
| `TransitionBaseCapturedSection(base, human, defence)` | captured, pearls per turn, the defenders of the level below (`UnitCountPanel`), the `PostDefencePanel`, and the descent button, off with the building it asks for named (`PostRequirement`) |
| `PostDefencePanel(post, defence)` | the largest faction army the scouts reported, what is lost if the post falls (the passage building, the units below, the reinforcements on their way) and that factions strike without warning |
| `RivalPostSheet(base, owner_name, refusal)` | a post another player holds (the volcano when `base` is null): who holds it, the refusal of an attack told in the sheet and the attack button off, `attack_requested` |
| `DescentDialog(available, target_level, base)` | an `UnitTransferDialog`: "Descent to level N", the post and its picture, the warning that it is final, "Descend (n units)" |
| `TransitionFightSummaryPage(result, x, y)` | an `AssaultSummaryPage` (`../fight/`): "Assault (x, y)", "base captured" |

## Not one to one

- The picture of a post is a `Portrait` (initials) tinted by its holder, until step 7
  (the 3D map already lights posts through `MapLooks`).
- Flutter shows the news of a descent in a snack bar: `MessageDialog` (`../common/`).
- The rival post sheet only tells `attack_requested`; `PostController` tells
  `rival_attack_requested` and `app/game/FactionController` runs the assault.
- The assault plan panel and gauge are in `../assault/`: the sections take a `plan` control.
- Sending reinforcements (`handleSendReinforcements`) has no caller in Flutter and
  is not ported; `ReinforcementDialog` stays in `../unit/`. The troops section of
  the Descent Module and Pressure Capsule building sheets (a descent from the
  base) is not ported either.
- No history report: the domain records a capture as a `CaptureEntry`, which
  Flutter does not reopen either.
