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
  and the army's parade ground and the map, one `WorldHost.View` at a time (base,
  parade, map or none, each with its own camera; the water and the sky are the base's);
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
    the game -> next turn -> question (threats due warned) -> turn ended (saved on the next frame)
      -> its story told on the map ("Passer" skips it) -> summary -> the reports of the raid, the predators and a kraken wave lost
      -> the card of an event drawn -> the game
    the game -> a turn lost it -> summary -> defeat screen -> menu, or the replay export over it
    the game -> the kernel at the last level -> victory screen over the game
      -> continue: free play, saved | menu: saved, then the menu
    new game, saved games -> menu: back

`game/` is the game played: `GameSession` holds the game, the repository and
the `GameActions`; each time an action succeeds (`acted`) it tells `changed` at
once and saves the game on the next frame (see "The save of a change" below);
`GameController` joins the `GameHud` and the
`WorldHost`: the tab on show decides what the world shows (`TabViews`: the base,
the parade ground or nothing, resting behind a page), `changed` redraws both, the island is framed between the bars, and
`quit_requested` and `language_chosen` go on to the flow. A tap on a pad of
the base (`BaseScene.building_tapped`) opens the sheet of its building
(`GameHud.open_building`); its upgrade goes through the actions, which redraw
(`acted`, then `changed`) and save: the HUD, the pads' levels and signs
(`BaseReadiness`: what can rise, what a prerequisite holds back) and the
rampart's tier. Flow: pad tapped -> sheet -> `GameActions.execute` -> `acted`
-> `changed` -> HUD and base redrawn -> next frame: saved. `AppFlow.play` builds
the three and `_leave_game` gives the world back to the menus.

The Tech tab is the research tree (`presentation/ui/tech/`), UI only: the tab
bar hides the world behind it like any tab but the base, a touch on a node opens
its sheet, and unlocking or researching goes through the same actions: node
touched -> sheet -> `GameActions.execute` -> `acted` -> `changed` ->
`GameHud.refresh()` redraws the tree. `GameController` has nothing of its own to
do for it. The tree is built again only while the Tech tab is on show: a change
made on another tab is drawn when the player comes to it (`TechTab`).

The army tab is the `ArmyController`, made by the `GameController`: it puts the
`ArmyTab` (`presentation/ui/army/`) over the world on the Army tab only and
writes the army the tab tells (`changed`, the roster at the place shown) as the
squads and the barracks of the `ParadeScene` (`ParadeStates`: the counts, the
captions in the language on, the plus of a type that can recruit, the padlock
of one the barracks is too low for). Flow: squad tapped
(`ParadeScene.squad_tapped`) -> `UnitSheet` -> recruit ->
`GameActions.execute` -> `acted` -> `changed` -> `ArmyTab.refresh` ->
`changed` -> parade redrawn; the barracks tapped opens its `BuildingSheet`.

The map tab is the `MapController`, made by the `GameController`: it puts the
`MapTab` (`presentation/ui/map/`) over the world on the Map tab only, and draws
the level the tab shows as the `MapScene` of the world (`MapStates`: the cells
seen, the base, the scouts on their way with the cell each left, the colours of
the rival bases and of whoever can hold the volcano, who holds the post above each
passage) while the tab is on show, again on each change of the game. Flow: cell
tapped (`MapScene.cell_tapped(level, x, y)`) -> `CellRouter.route` -> sheet ->
`GameActions.execute` -> `acted` -> `changed` -> `MapTab.refresh` and the
map redrawn; a search then tells what it found. A level chosen on the selector
(`MapTab.level_changed`) is drawn at once. For the other lots:
`map.router.register(CellRoute.Kind.POST | KERNEL | FACTION_BASE, handler)` opens
their sheet (the handler takes the `CellRoute` and opens its own modals), and
`map.show_level(level)` (after `hud.show_tab(GameTab.Value.MAP)`) shows a level
from a status bar or the guide.

The lairs are the `FightController` (`game/`), made by the `GameController`, which
registers for `CellRoute.Kind.LAIR`: a touch opens the `MonsterLairSheet`,
"prepare the fight" the `ArmySelection` page over the units of the level, and
launching runs `FightMonsterAction` through `GameActions.execute`. Flow: cell
tapped -> sheet -> `prepare_requested` -> selection -> `execute` -> `acted` ->
`changed` -> map redrawn (the lair of a victory dimmed, the stock and the noise
changed) -> the page closes with the result -> `FightSummaryPage`; a refusal
stays in the selection page. `FightController.report(result, route)` is where the
fight ends: it plays the strike on the map (`MapController.strike`, through
`StrikeReports.play`) and opens the report once it is over, and the history
reopens one with `HistoryReports.fight_summary(entry)`. The assaults on a post, on
the volcano and on a rival's base (`PostController`, `KernelController`,
`FactionController`) play their strike the same way before their reports open.
`MapController.siege(attack, then)` is the way in for the siege of the turn's story
(a raid, a wave, a rival's attack): see "The turn's story" below.

The posts are the `PostController` and the volcano the `KernelController` (`game/`), made by
the `GameController`, which register for `CellRoute.Kind.POST` and `KERNEL`: a touch opens
the `TransitionBaseSheet` or the `VolcanicKernelSheet` (or a `RivalPostSheet` for what a rival
holds). Flow of an assault: cell tapped -> sheet -> `assault_requested` -> `ArmySelection`
(`AssaultSelections`, an Admiral required) -> `AttackTransitionBaseAction` /
`AttackVolcanicKernelAction` through `GameActions.execute` -> `acted` -> `changed` ->
the page closes with the result -> `TransitionFightSummaryPage` / `KernelFightSummaryPage`; a
refusal stays in the page. Going down: `descend_requested` -> `DescentDialog` -> `DescendAction`
-> the map shows the level reached (`MapController.show_level`) and a `MessageDialog` tells it
(or why it was refused). The garrison: `garrison_requested` / `withdraw_requested` ->
`UnitPickerDialog` -> `GarrisonKernelAction` -> a `MessageDialog` with its size. The victory of
a kernel raised to the last level is `GameActions.victory_reached`, which the `GameController`
turns into the victory screen. A post or a volcano a rival holds tells
`rival_attack_requested(owner, level, x, y)` on its controller: `FactionController` (`faction/`,
`assault/`) listens to it and to the sheet of a rival base: `spy_requested` -> `SpyBaseAction` ->
the sheet again with the report; `attack_requested` -> `AssaultSelections.rival` ->
`AttackBaseAction` / `AttackPostAction` / `AttackHeldKernelAction` through `GameActions.execute` ->
the page closes with the result -> `AttackBaseEntries.for_attacker` -> `BaseAssaultSummaryPage`; a
refusal stays in the page, a refused spy is a `MessageDialog`.

The end of a turn is `EndTurnFlow` (`presentation/ui/turn/`), made by the
`GameController`: the HUD's `end_turn_requested` asks, the confirmed turn goes
through `GameActions.end_turn()` (so it is redrawn by `acted` before the
summary opens, and saved on the next frame), the pages of `TurnOutcome` open on
the `ModalLayer`, and
`finished` redraws the screen once the last is closed. `defeated` goes up to
`AppFlow.show_defeat`, which replaces the game with the `DefeatScreen` (the
world is the menus' again; its only way out is the menu); `AppFlow.play` shows
the same screen for a saved game already lost. A victory (`victory_reached`
of the actions, set by the action that raised the kernel to the last level)
opens the `VictoryScreen` over the game: "continue" sets free play through
`GameActions.continue_in_free_play` (saved, the same game goes on), "menu"
saves and leaves through `quit_requested`.

## The save of a change

A save costs more than the redraw it follows (about 25 ms against 10 on a
desktop, several times that on a phone), so it leaves the frame in which the
action shows. `GameSession` tells `changed` at once and asks a `NextFrame`
(`game/`) for the frame after: the tree tells `process_frame` in the very frame
of a touch, before drawing it, so `NextFrame` waits for the first one of a later
frame, by the engine's count. The changes of a frame are one save.

Nothing is lost on the ways out, where the next frame may never come or come
too late; each writes the save that waits at once:

- save and quit, and the victory screen's "menu": `GameSession.save()`, which
  saves whether or not a save waits;
- the game left for any other screen (the defeat screen of a turn that lost
  it, another game played): `GameController.close()` closes the session, which
  writes the save that waits, then saves and tells nothing more. A game is
  deleted from the saved games only, once left: nothing can write it back;
- the app going away or behind another (`App.LEAVING`): the `App` listens to
  the window closing (`NOTIFICATION_WM_CLOSE_REQUEST`, which a web page asked to
  quit sends too), the back key of Android (`WM_GO_BACK_REQUEST`), the window
  losing the focus (`WM_WINDOW_FOCUS_OUT`: on the web the canvas blurred, all
  the engine tells of a tab left), the app out of focus or paused by a phone
  (`APPLICATION_FOCUS_OUT`, `APPLICATION_PAUSED`) and its own leaving of the
  tree, and calls `AppFlow.flush()`.

A test gives the session a `NextFrame` on frames of its own (`ManualFrames`)
and makes them pass; elsewhere it flushes, since the tests run in one frame.

## The turn's story

After "Tour suivant" the turn is told on the map before its summary opens
(`game/story/`, Flutter's `game_screen_story.dart` and `screens/game/story/`). The turn
itself does not wait for it: it is resolved, redrawn by `acted` and saved as ever, and
`EndTurnFlow.observe` (`presentation/ui/turn/`) only holds the summary back.

    EndTurnFlow.observe -> StoryTeller.observe: TurnStorySnapshot.of(human)  (before the turn)
    GameActions.end_turn() -> turn_ended(result)
    StoryTeller._tell(result, then): TurnStory.plan -> chapters -> StoryPlayer -> then
    then -> TurnOutcome: the summary, the reports, the tips

- `TurnStory.plan(game, before, result)` is pure: the chapters, in Flutter's order. The
  fog lifting from the cells the scouts saw (`StoryFog`: the level where the most were
  seen, read against the `TurnStorySnapshot` taken before the turn), then the raid, the
  school of predators, the kraken wave on the volcano, then each attack of a faction or of
  the guardians on the base, a post or the volcano (`SiegeChapters`, `StoryPlaces`): a
  `StoryChapter` is a level and a `MapSiege`, or the fog. A turn with nothing to tell has
  no chapter and the summary opens at once.
- `StoryPlayer` plays the chapters one after the other: `MapController.tell_level` opens
  the Map tab on the chapter's level, then the siege is `MapController.siege` and the next
  chapter is its `then`. The time is the map's (`MapEffects` advance the effect playing,
  frame by frame; a test calls `effects.current.advance(seconds)`). The fog is the map's
  own lift (drawing a level lifts the fog from the cells seen since it was last drawn):
  the fog chapter opens the level and waits for it (`MapController.after_effects`).
- `skip()` finishes the effect playing (its last moment shown), plays no other chapter and
  tells the story over; it never tells twice, and `cancel()` (the screen closed) never tells.
  The "Passer" is the `StorySkipButton`, floated over the map's area by the `StoryTeller`
  while the story plays and taken away when it is over. Leaving the Map tab skips too: the
  world behind another tab is paused, its effects would never end.
- A player who asked for fewer animations (`reduced_motion` of the map's effects) is told
  no story and stays on his tab. No second turn can be asked during the story.

The threats show without `app/`: the `GameHud` stacks the raid, Leviathan and
kraken strips in its status bars (`ThreatBars`) and `session.changed` redraws
them with the rest; the warnings of the question and the reports after the
summary are read from the game and the turn's result by `EndTurnFlow`'s
`TurnWarnings` and `TurnOutcome`. Flow: turn ended -> `TurnResult` ->
`TurnOutcome` steps (`ThreatPages`) -> `RaidReportPage` or `VolcanoReportPage`
closed by "back to the base" -> the next step, or `finished` / `defeated`.

A save that cannot be read is skipped and named in a warning (and in
`AppFlow.unreadable`), never stopping the others; a save or a deletion that
fails is warned of and the player goes on. Tests give the app a `TempFolder` of
saves and settings (`app.repository`, `app.language`) before it enters the tree.

The 3D is drawn at twice the points at most, however dense the screen
(`RenderScale`, which the `App` applies to its window when it starts, before
the menus or a bench open: the base, the parade ground and the map all draw
in it). The game is fill-rate bound on a phone: the lighting, the shadows, the
map's fog and the glow are paid per pixel, and the web canvas follows the
screen's density, so an iPhone (density 3) would draw 2.6 million pixels where
density 2 draws 1.15. The scale is `min(1, 2 / density)`, the density being
`DisplayServer.screen_get_scale()` (the device pixel ratio on the web), read
once at startup: 2/3 on that iPhone (about 30 % off the frame time of the map
in a software render; `?bench=1` tells what it gives on a device). Only the
3D is scaled (`Viewport.scaling_3d_scale`, bilinear on the Compatibility
renderer): the 2D interface keeps every pixel, and nothing changes on a screen
of density 1 or 2. A test sets `app.density` before the app enters the tree.

The 3D prototype (`prototype/`) opens on the base with the frame counter and
the quality panel over it (`presentation/ui/perf/`): `QualitySettings` applies
the panel's choices (to the map too, when a bench measures one; its render
scales are shares of the scale the game draws at, so ×1 is the game's own, capped
on a dense screen, and the frame counter names the resolution really drawn,
"804×1428 (×0.67)"), `IdleFrameCap`
caps the frame rate at 30 while the view stands still, and `bench/` runs a fixed
path of the camera when the launch asks for one: `?bench=1` (`?bench=40` for 40 s)
in the web page's address, `-- --bench[=seconds]` on the command line. A launch with a
bench opens the prototype alone, in place of the menus, on the base, or on the map
of a level (`BenchGame`: a game against three factions, part of each level seen)
with `&scene=map&level=2` (`-- --bench --bench-scene=map --bench-level=2`): the map
then takes the base's place, its water lit as the level, and the camera loops over
it zooming in and out (`BenchPose`), which brings the contents' shadows on and off
(and the floor to take them or not) as a player's pinch does. The summary names the
scene it measured, on the frame counter (wrapped to a phone's width) and in the console:
"Bench 20 s on map level 2: 58.0 FPS avg · 49.0 FPS 1% low · worst 110 ms · 6 slow frames".
The 1 % low is the mean of the slowest hundredth of the frames; the worst frame and the
count of the slow ones (`FrameStats.slow_count`: longer than one and a half times the
run's median frame, so the same at 60 and 120 Hz) tell one long stop from a few frames
lost over the run.

With `&scene=game` (`-- --bench --bench-scene=game`) the bench measures what an action
of the player costs, on the real game in place of the prototype. The `App` plays the
`BenchGame` through the `AppFlow` as any game, on its Map tab, saved in a folder of its
own (`BenchSaves`: `user://bench` beside `user://saves`, never among the player's saves,
emptied before the bench and removed at its end), and the `BenchLayer` puts in the area
the bars leave clear the frame counter, which the game's HUD has not, and the `ActionBench`.
About twice a second the `ActionBench` plays a mark that changes nothing in the game
(`GameActions.mark`) but goes the whole way of an action: `acted`, the save, `changed`,
the redraw. Every frame is timed as in the other benches (`Bench` is what they share:
the warm-up, the frames timed, the summary), and for each action the longest of the
three frames that follow it is kept, since the save may fall on the frame after the
action's. The summary ends with their average and their worst: "Bench 20 s on game:
58.9 FPS avg · 31.0 FPS 1% low · worst 96 ms · 12 slow frames · action 88 ms avg, 96 worst".
The run ends once the frames of its last action are in, so the folder is removed after
that action's save. A frame's time is the `delta` the engine gives `_process`, which it
caps at about eight physics steps (some 130 ms): a longer stop counts as one of that
length. A launch without that bench has neither the counter nor the layer.

`tool/scene_capture.sh` renders the prototype and the app's screens.

`locale/AppLocale` is the language of the game: it reads the player's
`LanguageSettings` (`data/`), resolves AUTOMATIC from the device
(`OS.get_locale_language()`: French and Spanish as they are, English for any
other) and sets the `TranslationServer`, at startup and each time the setting
changes. `app.gd` builds both. The `.po` files it switches between are made
from the ARB files (`presentation/ui/l10n/README.md`); its `debug_reset()` puts
the language back to French between test files.

## The guide and the tips

`GameActions.guide` (a `GuideScope`) reads the tutorial's advice after every action,
before the session saves and redraws; the bubble, the objective banner and the 2D halos
(tabs, turn button, level chips, research) follow it themselves
(`presentation/ui/guide/README.md`). Two classes of `game/` join it to the rest:

- `GuideController`: on `guide.changed`, rings what the advice points at on the floor of
  the world: the pad of a building on the base, the drill pad of a unit on the parade
  ground, a cell on the map (`world.base.guide`, `world.parade.guide`, `world.map.guide`).
- `TipWatcher`: on `session.changed`, once the frame is drawn and when no modal covers
  the screen, opens the stack of the tips waiting (`TipPresenter`), which marks them seen
  first: one save with the action that brought them. The tips of a turn come last in its
  pages (`TurnOutcome`).

Both are made by the `GameController` and let go in `close()`.

## The web download

`.github/scripts/godot_export.sh Web build/web/index.html` writes `godot/build/web/`
(never committed). Measured at the end of step 7: `index.wasm` 39.5 MB (the engine's
stock single-thread template, 10.1 MB gzipped: nothing in the project shrinks it) and
`index.pck` 40.9 MB (22.6 MB gzipped), 81.5 MB in all (33.5 MB gzipped). The pck is
11.8 MB of ETC2 atlases and as much of S3TC ones (each device uses one of the two; the
preset keeps both so that iPhones, Androids and desktops all play; turning
`vram_texture_compression/for_desktop` off in the Web preset would save the second
half, at the price of desktop browsers without ETC2), 8.8 MB of models (the base's
island alone is 2.3 MB), 5.8 MB of icons and portraits and 1.2 MB of scripts.
The presets leave out the models no code loads (`leviathan`, `map_resource_*`,
`probe_fish`, `material_swatches`: 2.2 MB of the pck) and the Web preset the project
icon's texture; `assets/models/tests/export_filters_test.gd` fails if a script loads
one of them, so the day the Leviathan has a figure, take it off the filters.
