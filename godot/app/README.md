# app

Startup and navigation: the main scene, building the domain's state, choosing
which screen or world scene shows, and wiring the layers together.

The outermost layer: it may depend on every other one, and none depends on it.

## The app

`main.tscn` is the `App` (`app.gd`), the project's main scene. It gives the
window the game's theme, opens the saves (`GameRepository`) and the settings
(`LanguageSettings`), sets the language (`AppLocale`) and shows, bottom to top:

- `World` (`world/WorldHost`): the base in 3D (`presentation/world/`), drifting
  slowly around while a menu shows, the player's camera once a game is played;
- `Screens`: one screen at a time, kept off the notch (`SafeArea`);
- `Modals`: the `ModalLayer` dialogs and sheets open on.

`navigation/AppFlow` is the way between the screens, a chain of signals with no
`await`: the screens (`presentation/ui/`) only tell what the player wants, the
flow saves and deletes through the repository, reads the saves again each time
a screen is shown, and replaces the screen on show.

    menu -> new game -> (game created, saved) -> opening story -> the game
    menu -> saved games -> the game (a lost game opens its defeat screen)
    menu -> the game (continue: the latest in progress)
    the game -> settings -> save and quit -> (saved) -> menu
    the game -> settings -> language -> kept, the language set
    the game -> next turn -> question -> turn ended (saved) -> summary -> the game
    the game -> a turn lost it -> summary -> defeat screen -> menu
    the game -> the kernel at the last level -> victory screen over the game
      -> continue: free play, saved | menu: saved, then the menu
    new game, saved games -> menu: back

`game/` is the game played: `GameSession` holds the game, the repository and
the `GameActions`, and saves the game each time an action succeeds (`acted`)
before telling `changed`; `GameController` joins the `GameHud` and the
`WorldHost`: the tab on show decides whether the world shows (the base) or
rests, `changed` redraws both, the island is framed between the bars, and
`quit_requested` and `language_chosen` go on to the flow. A tap on a pad of
the base (`BaseScene.building_tapped`) opens the sheet of its building
(`GameHud.open_building`); its upgrade goes through the actions, which save
(`acted`) and redraw (`changed`): the HUD, the pads' levels and signs
(`BaseReadiness`: what can rise, what a prerequisite holds back) and the
rampart's tier. Flow: pad tapped -> sheet -> `GameActions.execute` -> `acted`
-> save -> `changed` -> HUD and base redrawn. `AppFlow.play` builds
the three and `_leave_game` gives the world back to the menus.

The Tech tab is the research tree (`presentation/ui/tech/`), UI only: the tab
bar hides the world behind it like any tab but the base, a touch on a node opens
its sheet, and unlocking or researching goes through the same actions: node
touched -> sheet -> `GameActions.execute` -> `acted` -> save -> `changed` ->
`GameHud.refresh()` redraws the tree. `GameController` has nothing of its own to
do for it.

The end of a turn is `EndTurnFlow` (`presentation/ui/turn/`), made by the
`GameController`: the HUD's `end_turn_requested` asks, the confirmed turn goes
through `GameActions.end_turn()` (so it is saved by `acted` and redrawn before
the summary opens), the pages of `TurnOutcome` open on the `ModalLayer`, and
`finished` redraws the screen once the last is closed. `defeated` goes up to
`AppFlow.show_defeat`, which replaces the game with the `DefeatScreen` (the
world is the menus' again; its only way out is the menu); `AppFlow.play` shows
the same screen for a saved game already lost. A victory (`victory_reached`
of the actions, set by the action that raised the kernel to the last level)
opens the `VictoryScreen` over the game: "continue" sets free play through
`GameActions.continue_in_free_play` (saved, the same game goes on), "menu"
saves and leaves through `quit_requested`.

A save that cannot be read is skipped and named in a warning (and in
`AppFlow.unreadable`), never stopping the others; a save or a deletion that
fails is warned of and the player goes on. Tests give the app a `TempFolder` of
saves and settings (`app.repository`, `app.language`) before it enters the tree.

The 3D prototype (`prototype/`) opens on the base with the frame counter and
the quality panel over it (`presentation/ui/perf/`): `QualitySettings` applies
the panel's choices, `IdleFrameCap` caps the frame rate at 30 while the view
stands still, and `bench/` runs a fixed orbit when the launch asks for one:
`?bench=1` (`?bench=40` for 40 s) in the web page's address,
`-- --bench[=seconds]` on the command line. A launch with a bench opens the
prototype alone, in place of the menus; `tool/scene_capture.sh` renders it, and
the app's screens.

`locale/AppLocale` is the language of the game: it reads the player's
`LanguageSettings` (`data/`), resolves AUTOMATIC from the device
(`OS.get_locale_language()`: French and Spanish as they are, English for any
other) and sets the `TranslationServer`, at startup and each time the setting
changes. `app.gd` builds both. The `.po` files it switches between are made
from the ARB files (`presentation/ui/l10n/README.md`); its `debug_reset()` puts
the language back to French between test files.
