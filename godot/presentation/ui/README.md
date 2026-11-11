# presentation/ui

The 2D interface: `Control` scenes and their scripts (resource bar, cards,
menus, sheets, dialogs), and the shared theme.

Depends on `domain/` to read the state it shows and to call the rules on the
player's actions. Never on `data/`, `app/` or `presentation/world/`.

## Subfolders

- `theme/`: the shared theme (`theme/README.md`).
- `common/`: the UI kit: the panel that follows the language, the modal layer
  with dialogs, bottom sheets and full pages, icons and portraits, and the
  small components (pills, banners, segmented bar, switch...)
  (`common/README.md`). Its tests run on `UiTestCase` (`tool/test/README.md`).
- `l10n/`: the texts. The ARB files of the Flutter version are turned into
  `fr.po`, `en.po` and `es.po` by `tool/arb_to_po.py` (checked in CI); `Texts.t`
  writes a message of the language on, `IcuFormat` its plurals and selects
  (`l10n/README.md`). A component never holds a text of its own: it asks
  `Texts` or one of the classes of `texts/`.
- `texts/`: one static class per Dart "name" extension (`BuildingTexts`,
  `UnitTexts`, `ResourceTexts`, `TechBranchTexts`, `TechNodeTexts`,
  `TerrainTexts`, `MonsterFamilyTexts`, `DifficultyTexts`,
  `LanguageChoiceTexts`, `ActionFailureTexts`, `RampartTexts`,
  `BuildingDegradationTexts`, `TransitionBaseTexts`, `MonsterLairTexts`), each tested for a key in
  all three languages. A key is built from the enum value's Dart name
  (`TextKeys`).
- `menu/`, `new_game/`, `save/`, `opening/`, `settings/`, `game/`: the screens of
  the app shell and their parts, each a `ScreenPage` or a `RefreshingPanel`
  that shows what it is given and tells what the player wants with signals:
  the main menu (`MainMenuScreen`: title, entries, beta notice, settings
  gear), the new game form with its pickers, the saved games (cards, list,
  empty state, confirmed deletion), the opening story and the language
  dialog, the settings of a game (`SettingsDialog`: language, guide and tip
  switches, save and quit) and the game screen (`game/`: `GameHud` with the
  resource bar, the content area left clear for the 3D base, the turn bar, the
  four tabs (`GameTabBar`) and a placeholder page for the tabs not built yet;
  `GameActions`, the one door the screen's actions go through, tells each
  success with `acted`; `TurnFigures` the production and consumption of a
  turn). They save and navigate nothing: `app/` does (`app/navigation/app_flow.gd`,
  `app/game/`).
- `turn/`: the end of a turn (`turn/README.md`): the question (`TurnConfirmation`),
  the summary (`TurnSummary`), the queue of pages `TurnOutcome` and the chain
  that joins them, `EndTurnFlow`.
- `game_over/`: the end of a game: `DefeatScreen` and `VictoryScreen`, two
  configurations of `GameOverScreen`, with the statistics and the cause of a
  fall (`GameOverScreens` builds them from a game).
- `building/`: a building of the base (`BuildingSheet`, the bottom sheet a tap on
  a pad opens: `BuildingHeader`, the `UpgradeSection` with its `RequirementRow`s
  and `NoiseCostRow`, the `CitadelSection`, the `DegradedBadge`; `BuildingCard`
  for a list; `BaseBanners` over the base: `WorksiteBadge`, `ShieldBadge`).
  A sheet reads the game through a `BuildingView` taken at one moment and
  redraws on `refresh()`; it changes the game only through `GameActions`, closes
  with the result when the upgrade succeeds and tells a refusal in itself.
  The colour of each building is `theme/BuildingColors`.
- `tech/`: the research (`tech/README.md`): the tree of the Tech tab (`TechTab`,
  `TechTreeView`: the laboratory, three columns of medallion and nodes in four
  states) and the sheet a touch opens (`TechTargetSheet`: effect, cost or
  blocker, the two options of a choice). Built from a `TechView` of the game;
  unlocking and researching go through `GameActions`.
- `threat/`: the parts of the raid gauge (`NoiseCostRow`).
- `resource/`: the resource bar (`ResourceBar`, a `ResourceBarItem` per
  resource with its amount, rate and shortage state, `AnimatedAmount` flashing
  and popping when an amount changes), the detail sheet a touch opens and the
  gain dialog and row.
