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
  `LanguageChoiceTexts`, `ActionFailureTexts`), each tested for a key in all
  three languages. A key is built from the enum value's Dart name
  (`TextKeys`).
- `menu/`, `new_game/`, `save/`, `opening/`, `settings/`, `game/`: the screens of
  the app shell and their parts, each a `ScreenPage` or a `RefreshingPanel`
  that shows what it is given and tells what the player wants with signals:
  the main menu (`MainMenuScreen`: title, entries, beta notice, settings
  gear), the new game form with its pickers, the saved games (cards, list,
  empty state, confirmed deletion), the opening story and the language
  dialog, and `GamePlaceholderScreen`, what stands for the game until the base,
  the map and the army are built. They save and navigate nothing: `app/` does
  (`app/navigation/app_flow.gd`).
- `resource/`: the strip of resource amounts (`ResourceAmountStrip`).
