# tool/scene

Review renders of the game's 3D prototype and screens, not game code, left out
of exports.

    tool/scene_capture.sh [out dir] [scene | app | base | kit]

`capture.gd` opens `app/prototype/prototype.tscn` (or `scene`) in a window the size of a
phone held upright at 2x (780 x 1688, the project's 390 x 844 points), lets
it run 240 frames, then writes `default.png` (the game's view),
`rotated.png`, `close.png` (zoomed on the headquarters) and `top.png` (from
above, the quality panel open), printing each view's draw calls, primitives
and objects. Godot draws with its Compatibility renderer (the web's) under
`xvfb-run`, in software: its frame rate means nothing, its draw calls and
primitives do. The renders go to `/tmp/scene_capture/` by default: never into
the repo.

## The app

`app_capture.gd` (`tool/scene_capture.sh [out dir] app`, or after the base's
views when no scene is given) runs `app/main.tscn` on saves of its own, written
under `user://` and removed at the end, in French, and renders what the player
meets: `app_menu_empty.png` (the menu with no save: two entries), `app_menu.png`
(three saves: the continue shortcut, the count badge), `app_new_game.png`,
`app_saves.png` (the list, the latest game glowing), `app_story.png` (the first
card of the opening story) `app_game.png` (the game screen: the resource bar with
the energy shortage in red, the island with the buildings built, the turn bar
and the tabs), `app_game_settings.png` (the settings dialog over it),
`app_game_resource.png` (the energy detail sheet) and `app_game_tech.png` (a
tab not built yet, the world hidden), each with its draw calls and primitives. Never commit the renders.

## The base and its buildings

`base_capture.gd` (`tool/scene_capture.sh [out dir] base`, or after the app's
shots when no scene is given) plays a game whose base shows every state of a
pad and renders: `base_standins.png` (the eleven pads as stand-ins: a shape
and a colour per building, the level over each, the arrow of a building that can
rise, the warning of a degraded one, the plus of a plot to build on, the padlock
of one held back, and the banners of the worksites and the rampart at the top
left), `base_close.png` (the same, nearer), `base_models.png` (the models there
are, in place of their stand-ins) and the sheets of a building that can rise,
a degraded one, the Coral Citadel and a plot held back by a prerequisite
(`base_sheet_upgrade.png`, `_degraded.png`, `_citadel.png`, `_locked.png`), each
with its draw calls and primitives. Never commit the renders.

## The UI kit

`kit_capture.gd` (`tool/scene_capture.sh [out dir] kit`, or after the base's
views when no scene is given) renders the components of `presentation/ui/common`
laid out by `kit_gallery.gd` with the sample data of `kit_parts.gd`:
`kit_a.png` (pills, badge, banners, segmented bar, switches, lore), `kit_b.png`
(resource, technology, event and guide icons, portraits, the guide halo, the
tab placeholder), `kit_b_en.png` (the same page after the language changed to
English, without a rebuild), and `kit_dialog.png`, `kit_sheet.png` and
`kit_page.png` (a dialog, a bottom sheet and a full page over the first page),
each with its draw calls and primitives. Review tooling, not game code; never
commit the renders.
