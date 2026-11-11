# presentation/ui/tech

The research: the laboratory tab and the sheet a touch on it opens, ported from
`lib/presentation/widgets/tech/` (not the painters), `game_screen_tech_actions`
and the `tech_*_extensions`. Depends on `domain/`, `../common`, `../l10n`,
`../texts` and `../theme` only: it saves and navigates nothing, `app/` does.

## The tab

`TechTab` (a `RefreshingPanel`, the page of the Tech tab in `GameHud`, over the
world, which rests hidden behind it) shows the `TechTreeView` and builds it
again from the game on `refresh()`, which the HUD calls after each change. A
touch on a node or a medallion opens a `TechTargetSheet` on the modals.

    node or medallion touched -> TechTreeView.target_tapped(TechTarget)
      -> TechTab opens a TechTargetSheet
      -> its button: GameActions.execute(UnlockBranchAction | ResearchTechAction)
      -> success: acted -> GameSession saves -> changed -> GameHud.refresh()
         -> TechTab.refresh(); the sheet closes with the ActionResult
      -> refusal: told in the sheet (ActionFailureTexts), which reads the game
         again and stays open

## The tree

| Component | Role |
| --- | --- |
| `TechTreeView` | the laboratory (`TechLabEmblem`) at the head, a notice while it stands to build, the three `TechBranchColumn`s; `target_tapped(target)` |
| `TechBranchColumn` | a branch running down: a `TechBranchMedallion`, then its five levels, a `TechLink` above each, the levels 2 and 4 with two `TechNode`s side by side; `nodes` by name ("1", "2a", "2b"...), `node_at(level, option)` |
| `TechBranchMedallion` | the round emblem of a branch: its colour and glow once unlocked, grey with a padlock otherwise, its name and level under it |
| `TechNode` | a technology's icon in a round frame, in one of the four `TechNodeState`s: researched (glowing), accessible (ringed), locked (faded, grey), discarded (grey, struck through) |
| `TechLink` | the thread between two nodes: lit in the branch's colour as far as the research went |
| `TechLabEmblem` | the laboratory's picture and level, teal once built |

## The sheet

| Component | Role |
| --- | --- |
| `TechTargetSheet` | the `BottomSheet`: the panel, and the refusal of the last attempt. Runs the action; closes on success |
| `TechTargetPanel` | the card: header, the two options of a choice node, then "Acquis", the blocker or the cost |
| `TechTargetHeader` | icon, name and effect of the target, and its "Débloquer" / "Rechercher" button (none on a choice, which carries its buttons in the options) |
| `TechChoiceRow` / `TechOptionCard` | the two exclusive options face to face; each open, taken or discarded |
| `TechCostRow` | the costs on a line, in red what the stock cannot pay |

## What they read

`TechView.of(game)` takes the game at one moment: how each node stands, whether
a target is done, what blocks it (no laboratory, the branch to unlock first,
the level before, the laboratory too low, one research a turn), what it costs
and the factor each new branch adds. `TechTarget` names a branch or one of its
levels (level 0 is the branch, where Dart has null). `TechColors` and
`TechIcons` give a branch its colour and its pictures: the 21 icons of
`assets/icons/tech/`, and an emblem per branch.

## Not one to one

- Flutter lays the tree out as a sonar, the laboratory in the middle and the
  three branches as spokes drawn with `TechReefPainter` and `DashedRingPainter`.
  Here the branches are three columns under the laboratory and the threads are
  thin panels: the same on a phone, with no painter. An accessible node is
  ringed with a plain rim, not dashes.
- A greyed icon (`RasterSvg(greyscale: true)`) is drawn by `common/Greyscale`, a
  shader.
- The military and explorer emblems are the barracks and scout SVGs of the
  world in Flutter; here the shield and compass glyphs, tinted in the branch's
  colour (the resources branch keeps the algae icon).
- Flutter closes the popup whatever the action did and ignores a refusal; here
  the sheet stays open and tells it, since a refusal means the game moved since
  the sheet was built.
- While the laboratory is to build, a notice at the top says so (Flutter tells
  it in the panel of a branch only); the panel says it too.
- The guide's halo around a branch or a node is lot 15's: the components take
  no `guide_target` yet.

The tests are in `tests/`, on `TechTestCase` (a new game and helpers to set the
laboratory and the branches). `tool/scene_capture.sh [out dir] tech` renders the
tab and its sheets (`tool/scene/README.md`).
