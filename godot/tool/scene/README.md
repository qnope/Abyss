# tool/scene

Review renders of the game's 3D prototype and screens, not game code, left out
of exports.

    tool/scene_capture.sh [out dir] [scene | app | base | army | turn | tech | threat | kit]

    tool/scene_capture.sh [out dir] [scene | app | base | army | map | turn | kit]

    tool/scene_capture.sh [out dir] [scene | app | base | army | turn | tech | event | kit]

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
`app_game_resource.png` (the energy detail sheet) and `app_game_tech.png` (the
research tab of that game, the world hidden), each with its draw calls and primitives. Never commit the renders.

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

## The army

`army_capture.gd` (`tool/scene_capture.sh [out dir] army`, or after the base's
shots when no scene is given) plays a game whose army serves on two levels,
with a barracks at level 3 and full stores, opens the Army tab and renders:
`army_parade.png` (the parade ground: a squad of stand-ins on each of the six
pads, a shape and a colour per unit, its count and name over it, the green plus
where recruiting is possible, a ghost and a padlock where the barracks is too
low, the barracks at the back and the bar of places at the foot),
`army_places.png` (the second level only), `army_close.png` (nearer),
`army_sheet_unit.png` and `army_sheet_recruit.png` (the sheet of a unit, then
with four to recruit: the cost in resources, the noise), `army_sheet_locked.png`
(a unit the barracks is too low for), `army_reinforcement.png` and
`army_picker.png` (the dialogs that pick units) and `army_barracks_empty.png`
(no barracks yet), each with its draw calls and primitives. Never commit the
renders.

## The map

`map_capture.gd` (`tool/scene_capture.sh [out dir] map`, or after the army's shots
when no scene is given) plays a game against three factions, the surface seen
around the base (the rest in the dark), ruins and a treasure beside it, three
scouts and one of them on its way, the other depths seen where a passage and
the volcano lie, opens the Map tab and renders: `map_level1.png`,
`map_level2.png` and `map_level3.png` (a level each: seen tiles in blue-grey,
the fog dark and lower, stand-ins of the lairs, treasures, ruins, posts, the
player's base and the volcano, the selector at the top with the level on show
filled), `map_close.png` (the camera brought close), `map_exploration_sheet.png`
(a hidden cell next to the seen ones: cost, scouts, area and noise),
`map_exploration_storm.png` (the same under a storm: the button off and the
reason), `map_treasure_sheet.png`, `map_found.png` (what the search gave) and
`map_visited.png` (the cell once searched), each with its draw calls and
primitives. Never commit the renders.

## The end of a turn and of a game

`turn_capture.gd` (`tool/scene_capture.sh [out dir] turn`, or after the kit's
views when no scene is given) plays a game three turns through the real
screens, then stops its algae and energy and renders: `turn_confirm.png` (the
question: what the base will make, the buildings that will shut down, the units
that will starve), `turn_summary.png` (what the turn did), `turn_summary_en.png`
(the same after the language changed), `turn_victory.png` and `turn_defeat.png`
(the two screens of a game's end), each with its draw calls and primitives.
Never commit the renders.

## The research

`tech_capture.gd` (`tool/scene_capture.sh [out dir] tech`, or after the end of a
turn's views when no scene is given) plays a new game and then a game in the
middle of its research (a laboratory 3, the military branch to its second level
with the second option taken, the resources branch to its third, the explorer one
just opened) and renders: `tech_new.png` (no laboratory: the notice, every node
locked), `tech_tree.png` and `tech_tree_en.png` (the tree in French and in
English: researched, accessible, locked and discarded nodes, the threads lit as
far as the research went), and the sheets of a touch: `tech_node.png` (a node to
research, its effect and cost), `tech_choice.png` (a choice, two options face to
face), `tech_done.png` (a choice already made), `tech_blocked.png` (a choice held
back by the laboratory) and `tech_branch.png` (a branch to unlock, with the
surcharge), each with its draw calls and primitives. Never commit the renders.

## The events, the history and the replay export

`event_capture.gd` (`tool/scene_capture.sh [out dir] event`, or after the
research's views when no scene is given) plays a game at turn 8 with a survivors
event waiting and a history of every kind of entry, and renders:
`event_strip.png` (the strip under the resource bar that reminds of the event),
`event_card.png` and `event_card_en.png` (the card of the survivors over the
game: the picture, two lines, the filled first option, the outlined prudent one
and "later"), `event_card_trade.png` (the caravan's trade with the stock empty:
the first option greyed with its reason under it), `history_settings.png` (the
settings with the history and export rows), `history_all.png`,
`history_combat.png` and `history_en.png` (the sheet, 80% high: the filter chips
and the tinted cards, newest first; a combat filter keeps the fights, raids and
the kraken wave), `export_dialog.png`, `export_copied.png` (the confirmation line
after a copy) and `export_old.png` (a game with no journal), each with its draw
calls and primitives. Never commit the renders.

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

## The threats

`threat_capture.gd` (`tool/scene_capture.sh [out dir] threat`, or after the
research's views when no scene is given) plays a game where the guardians strike
the Faille, a kraken wave rises and a raid is due, through the real screens, and
renders: `threat_bars.png` (the game screen under the resource bar: the noise
gauge and the raids lost in a row, the red strip of the guardians, the kraken
wave's) and `threat_bars_raid.png` (the raid alert in place of the gauge),
`threat_confirm.png` (the question with the raid, the school of predators, the
guardians and the kraken wave all warned of), `threat_summary.png` (the turn's
lines), `threat_summary_announced.png` (a raid and a wave announced),
`threat_raid_report.png`, `threat_raid_report_end.png` (the report of a raid
lost, top and foot), `threat_predators_report.png` (the school of predators), `threat_raid_report_won.png` (a raid won behind a rampart),
`threat_wave_report.png` and `threat_wave_report_en.png` (the kernel taken a
level), each with its draw calls and primitives. Never commit the renders.
