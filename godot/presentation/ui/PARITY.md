# Parity with the Flutter interface

Every file of `lib/presentation/screens/` and `lib/presentation/widgets/` with the
Godot class that holds its job, or the reason it has none. A path is relative to
`godot/presentation/` (`ui/...`, `world/...`) or to `godot/` (`app/...`). The Flutter
version stays the spec until the switch; its tests are ported one for one next to each
class (`tests/`).

How to read a row:

- A class name alone: ported, with the same behaviour (the three languages included).
- **Replaced by 3D**: Flutter painted it on a canvas; the Godot version is a 3D scene of
  `presentation/world/` (the base, the parade ground, the map, the guide's rings), so the
  painters, projections, hit tests and sprite plumbing of those folders have no file of
  their own.
- **Not needed**: Flutter plumbing the engine does itself (raster caches, sprite atlases,
  the shared animation clock, the pre-warming of images).
- **Missing**: not done. Everything missing is listed in the summary below.

## What is still missing

These are gaps of the interface, not of the rules: `godot/domain` is complete.

1. **The animations of step 7.** The turn's story on the map (`screens/game/story/`,
   `game_screen_story.dart`, its skip button), the strike, siege and fog-lift effects of
   the map (`widgets/map/effects/`), the creatures drawn alive on the map
   (`living_creatures.dart`, `map_creature_sheets.dart`, `map_cell_motion.dart`), the
   decor scattered on the map's floor (`widgets/map/decor/`), the squads' arrival on the
   parade ground (`army_arrival*`, `squad_arrival`). The figures that float and pop when a
   resource changes and the glow of a building that can rise are done (`DeltaFloat`,
   `IncreasePop`, `PadHalos`).
2. **The pictures of buildings, units, posts and monsters** are `Portrait`s (initials on a
   tinted panel) until step 7 fills them with renders of the 3D models. This touches the
   cards, the sheets and the tips' illustrations (`TipIllustrations`).
3. **The cards peeking behind the front tip** (`tip_stack.dart`): the stack shows one card
   at a time, with « n / m », « Suivant » and the swipe.
4. **The halo on a card.** Flutter draws the guide's halo around the card of a building
   (`base_slot_halo`) or of a unit (`army_guide_halo`); here the ring lies on the floor of
   the 3D base and of the parade ground (`world/guide/`), and the buttons of a sheet are
   not haloed. The halos of the tabs, the turn button, the level chips, the research and
   the kernel's garrison button are 2D and follow the guide (`ui/guide/`).
5. **Smaller differences.** The halos are rounded rectangles or circles (`GuideHalo`), not
   Flutter's traced paths; the title of the objectives sheet scrolls with its list where
   Flutter keeps it above.

## Not under screens/ and widgets/

| Flutter | Godot |
| --- | --- |
| `abyss_material_app.dart` | `App` (app/app.gd), `AbyssTheme` (ui/theme/abyss_theme.gd) |
| `app_version.dart` | `AppVersion` (ui/menu/app_version.gd) |
| `theme/*.dart` | `ui/theme/` (`AbyssColors`, `AbyssMotion`, the `Abyss*Theme` classes, `BuildingColors`, `UnitColors`, `FactionColors`...); the backdrop, trench, slab, island and base-badge themes belong to Flutter's canvases and have no counterpart (`world/models/WorldPalette` colours the 3D scenes) |
| `extensions/*.dart` | `ui/texts/` (one static class per Dart extension, `...Texts`), each tested for the three languages |
| `l10n/` | `ui/l10n/` (`.po` files made from the ARB files, `Texts.t`) |

## File by file

### `lib/presentation/screens/game/`

| Flutter file | Godot |
| --- | --- |
| `defeat_screen.dart` | `DefeatScreen` (ui/game_over/defeat_screen.gd) |
| `descent_dialog.dart` | `DescentDialog` (ui/post/descent_dialog.gd) |
| `game_over_screen.dart` | `GameOverScreen` (ui/game_over/game_over_screen.gd) |
| `game_screen.dart` | `GameHud` (ui/game/game_hud.gd), `GameController` (app/game/game_controller.gd) |
| `game_screen_actions.dart` | `GameActions` (ui/game/game_actions.gd) |
| `game_screen_army_tab.dart` | `ArmyController` (app/game/army_controller.gd) |
| `game_screen_assault_plan.dart` | `AssaultPlans` (ui/assault/assault_plans.gd), `FightController` (app/game/fight_controller.gd) |
| `game_screen_base_sheet.dart` | `GameHud` (ui/game/game_hud.gd) (`open_building`) |
| `game_screen_collect_messages.dart` | `CollectMessages` (ui/map/collect_messages.gd) |
| `game_screen_collected_cell.dart` | `MapController` (app/game/map_controller.gd) |
| `game_screen_defeat_actions.dart` | `AppFlow` (app/navigation/app_flow.gd) |
| `game_screen_end_turn.dart` | `EndTurnFlow` (ui/turn/end_turn_flow.gd) |
| `game_screen_event_actions.dart` | `EventStep` (ui/event/event_step.gd) |
| `game_screen_exploration_flow.dart` | `ExplorationSheet` (ui/map/exploration_sheet.gd), `MapController` (app/game/map_controller.gd) |
| `game_screen_faction_actions.dart` | `FactionController` (app/game/faction_controller.gd) |
| `game_screen_fight_actions.dart` | `FightController` (app/game/fight_controller.gd) |
| `game_screen_kernel_actions.dart` | `KernelController` (app/game/kernel_controller.gd) |
| `game_screen_map_actions.dart` | `MapController` (app/game/map_controller.gd) |
| `game_screen_rival_attack.dart` | `FactionController` (app/game/faction_controller.gd) |
| `game_screen_settings_actions.dart` | `GameHud` (ui/game/game_hud.gd), `SettingsFollowUp` (ui/settings/settings_follow_up.gd) (`open_settings`) |
| `game_screen_story.dart` | **Missing.** The turn story (step 7: the animations of the turn on the map). |
| `game_screen_tabs.dart` | `GameTab` (ui/game/game_tab.gd), `GameTabBar` (ui/game/game_tab_bar.gd), `TabViews` (app/game/tab_views.gd) |
| `game_screen_tech_actions.dart` | `TechTab` (ui/tech/tech_tab.gd), `GameActions` (ui/game/game_actions.gd) |
| `game_screen_transition_actions.dart` | `PostController` (app/game/post_controller.gd) |
| `game_screen_transition_attack.dart` | `PostController` (app/game/post_controller.gd) |
| `game_screen_troops_actions.dart` | `ArmyController` (app/game/army_controller.gd) |
| `game_screen_turn_flow.dart` | `TurnOutcome` (ui/turn/turn_outcome.gd) |
| `game_screen_turn_helpers.dart` | `TurnOutcome` (ui/turn/turn_outcome.gd), `EndTurnFlow` (ui/turn/end_turn_flow.gd) |
| `game_screen_victory_actions.dart` | `GameController` (app/game/game_controller.gd) (`_on_victory`), `VictoryScreen` (ui/game_over/victory_screen.gd) |
| `reinforcement_dialog.dart` | `ReinforcementDialog` (ui/unit/reinforcement_dialog.gd) |
| `resume_game.dart` | `AppFlow` (app/navigation/app_flow.gd) |
| `victory_screen.dart` | `VictoryScreen` (ui/game_over/victory_screen.gd) |

### `lib/presentation/screens/game/fight/`

| Flutter file | Godot |
| --- | --- |
| `army_selection_screen.dart` | `ArmySelection` (ui/fight/army_selection.gd) |
| `army_selection_summary.dart` | `ArmySelectionSummary` (ui/fight/army_selection_summary.gd) |
| `assault_selection_body.dart` | `AssaultSelections` (ui/fight/assault_selections.gd) |
| `base_army_selection_screen.dart` | `AssaultSelections` (ui/fight/assault_selections.gd) |
| `base_assault_summary_screen.dart` | `BaseAssaultSummaryPage` (ui/assault/base_assault_summary_page.gd) |
| `fight_summary_screen.dart` | `FightSummaryPage` (ui/fight/fight_summary_page.gd) |
| `kernel_army_selection_screen.dart` | `AssaultSelections` (ui/fight/assault_selections.gd) |
| `kernel_fight_summary_screen.dart` | `KernelFightSummaryPage` (ui/kernel/kernel_fight_summary_page.gd) |
| `transition_army_selection_screen.dart` | `AssaultSelections` (ui/fight/assault_selections.gd) |
| `transition_fight_summary_screen.dart` | `TransitionFightSummaryPage` (ui/post/transition_fight_summary_page.gd) |

### `lib/presentation/screens/game/raid/`

| Flutter file | Godot |
| --- | --- |
| `raid_pillage_card.dart` | `RaidPillageCard` (ui/threat/raid_pillage_card.gd) |
| `raid_summary_screen.dart` | `RaidReportPage` (ui/threat/raid_report_page.gd) |

### `lib/presentation/screens/game/story/`

| Flutter file | Godot |
| --- | --- |
| `attack_chapter.dart` | **Missing.** The turn story (step 7). |
| `story_chapter.dart` | **Missing.** The turn story (step 7). |
| `story_places.dart` | **Missing.** The turn story (step 7). |
| `turn_story.dart` | **Missing.** The turn story (step 7). |
| `turn_story_fog.dart` | **Missing.** The turn story (step 7). |
| `turn_story_snapshot.dart` | **Missing.** The turn story (step 7). |

### `lib/presentation/screens/game/volcano/`

| Flutter file | Godot |
| --- | --- |
| `volcano_summary_screen.dart` | `VolcanoReportPage` (ui/threat/volcano_report_page.gd) |

### `lib/presentation/screens/menu/`

| Flutter file | Godot |
| --- | --- |
| `load_game_screen.dart` | `LoadGameScreen` (ui/save/load_game_screen.gd) |
| `main_menu_screen.dart` | `MainMenuScreen` (ui/menu/main_menu_screen.gd) |
| `new_game_screen.dart` | `NewGameScreen` (ui/new_game/new_game_screen.gd) |
| `opening_story_screen.dart` | `OpeningStoryScreen` (ui/opening/opening_story_screen.gd) |

### `lib/presentation/widgets/ambience/`

| Flutter file | Godot |
| --- | --- |
| `ambience_clock.dart` | Not needed: Flutter's shared animation clock; the engine's frame time serves. |
| `ambience_clock_scope.dart` | Not needed: Flutter's shared animation clock; the engine's frame time serves. |
| `ambient_bubbles.dart` | Replaced by 3D: `RisingBubbles` (world/ambience/rising_bubbles.gd) |
| `ambient_motion.dart` | Replaced by 3D: The pose and undulation of the 2D sprites are the 3D models' own motion: `BaseMotion` (world/base/base_motion.gd). |
| `ambient_pose.dart` | Replaced by 3D: The pose and undulation of the 2D sprites are the 3D models' own motion: `BaseMotion` (world/base/base_motion.gd). |
| `bubbles_painter.dart` | Replaced by 3D: `RisingBubbles` (world/ambience/rising_bubbles.gd) |
| `creature_sheet.dart` | Replaced by 3D: The pose and undulation of the 2D sprites are the 3D models' own motion: `BaseMotion` (world/base/base_motion.gd). |
| `creature_undulation.dart` | Replaced by 3D: The pose and undulation of the 2D sprites are the 3D models' own motion: `BaseMotion` (world/base/base_motion.gd). |
| `delta_float.dart` | `DeltaFloat` (ui/common/delta_float.gd): on the resource bar (`AnimatedAmount`) and the unit card |
| `increase_pop.dart` | `IncreasePop` (ui/common/increase_pop.gd): on the pictures of `BuildingCard` and `UnitCard` |
| `pose_box.dart` | Replaced by 3D: The pose and undulation of the 2D sprites are the 3D models' own motion: `BaseMotion` (world/base/base_motion.gd). |
| `rise_glow_painter.dart` | `IncreasePop`'s two glow discs (ui/common/increase_pop.gd); the glow of a building that can rise is `PadHalos` (world/base/pad_halos.gd), beside the arrow `PadMark` |
| `rise_motion.dart` | `IncreasePop.scale_at`, `drop_at` and `glow_at` (ui/common/increase_pop.gd) |
| `sprite_motion.dart` | Replaced by 3D: The pose and undulation of the 2D sprites are the 3D models' own motion: `BaseMotion` (world/base/base_motion.gd). |

### `lib/presentation/widgets/army/`

| Flutter file | Godot |
| --- | --- |
| `army_arrival_drawer.dart` | **Missing.** The squads' arrival animation (step 7). |
| `army_arrivals.dart` | **Missing.** The squads' arrival animation (step 7). |
| `army_banner_drawer.dart` | Replaced by 3D: The army's parade ground is drawn in 3D: `ParadeScene` (world/parade/parade_scene.gd), `ParadeGround` (world/parade/parade_ground.gd). |
| `army_barracks_drawer.dart` | Replaced by 3D: `ParadeBarracks` (world/parade/parade_barracks.gd) |
| `army_crate_drawer.dart` | Replaced by 3D: The army's parade ground is drawn in 3D: `ParadeScene` (world/parade/parade_scene.gd), `ParadeGround` (world/parade/parade_ground.gd). |
| `army_crest_drawer.dart` | Replaced by 3D: The army's parade ground is drawn in 3D: `ParadeScene` (world/parade/parade_scene.gd), `ParadeGround` (world/parade/parade_ground.gd). |
| `army_decor.dart` | Replaced by 3D: The army's parade ground is drawn in 3D: `ParadeScene` (world/parade/parade_scene.gd), `ParadeGround` (world/parade/parade_ground.gd). |
| `army_depot_drawer.dart` | Replaced by 3D: The army's parade ground is drawn in 3D: `ParadeScene` (world/parade/parade_scene.gd), `ParadeGround` (world/parade/parade_ground.gd). |
| `army_draw_order.dart` | Replaced by 3D: The army's parade ground is drawn in 3D: `ParadeScene` (world/parade/parade_scene.gd), `ParadeGround` (world/parade/parade_ground.gd). |
| `army_drill_pad_drawer.dart` | Replaced by 3D: The army's parade ground is drawn in 3D: `ParadeScene` (world/parade/parade_scene.gd), `ParadeGround` (world/parade/parade_ground.gd). |
| `army_fit.dart` | Replaced by 3D: The army's parade ground is drawn in 3D: `ParadeScene` (world/parade/parade_scene.gd), `ParadeGround` (world/parade/parade_ground.gd). |
| `army_guide_halo.dart` | `GuideRing` (world/guide/guide_ring.gd) (on the squad's drill pad), aimed by `GuideController` (app/game/guide_controller.gd) |
| `army_helmet_bubbles.dart` | Replaced by 3D: The army's parade ground is drawn in 3D: `ParadeScene` (world/parade/parade_scene.gd), `ParadeGround` (world/parade/parade_ground.gd). |
| `army_hit.dart` | Replaced by 3D: `ParadePick` (world/parade/parade_pick.gd) |
| `army_island_painter.dart` | Replaced by 3D: The army's parade ground is drawn in 3D: `ParadeScene` (world/parade/parade_scene.gd), `ParadeGround` (world/parade/parade_ground.gd). |
| `army_layers.dart` | Replaced by 3D: The army's parade ground is drawn in 3D: `ParadeScene` (world/parade/parade_scene.gd), `ParadeGround` (world/parade/parade_ground.gd). |
| `army_layout.dart` | Replaced by 3D: `ParadeLayout` (world/parade/parade_layout.gd) |
| `army_marks_painter.dart` | Replaced by 3D: `PadMark` (world/base/pad_mark.gd) |
| `army_piece.dart` | Replaced by 3D: The army's parade ground is drawn in 3D: `ParadeScene` (world/parade/parade_scene.gd), `ParadeGround` (world/parade/parade_ground.gd). |
| `army_place_bar.dart` | `ArmyPlaceBar` (ui/army/army_place_bar.gd) |
| `army_places.dart` | `ArmyPlaces` (ui/army/army_places.gd) |
| `army_places_view.dart` | `ArmyPlaces` (ui/army/army_places.gd) |
| `army_plaque.dart` | Replaced by 3D: `SquadPlaque` (world/parade/squad_plaque.gd) |
| `army_plaque_arrival_drawer.dart` | Replaced by 3D: `SquadPlaque` (world/parade/squad_plaque.gd) |
| `army_plaque_drawer.dart` | Replaced by 3D: `SquadPlaque` (world/parade/squad_plaque.gd) |
| `army_rampart.dart` | Replaced by 3D: The army's parade ground is drawn in 3D: `ParadeScene` (world/parade/parade_scene.gd), `ParadeGround` (world/parade/parade_ground.gd). |
| `army_roster.dart` | `ArmyRoster` (ui/army/army_roster.gd) |
| `army_semantics.dart` | Replaced by 3D: The army's parade ground is drawn in 3D: `ParadeScene` (world/parade/parade_scene.gd), `ParadeGround` (world/parade/parade_ground.gd). |
| `army_slots.dart` | Replaced by 3D: The army's parade ground is drawn in 3D: `ParadeScene` (world/parade/parade_scene.gd), `ParadeGround` (world/parade/parade_ground.gd). |
| `army_sprites.dart` | Replaced by 3D: The army's parade ground is drawn in 3D: `ParadeScene` (world/parade/parade_scene.gd), `ParadeGround` (world/parade/parade_ground.gd). |
| `army_squad_drawer.dart` | Replaced by 3D: `Squad` (world/parade/squad.gd), `SquadSize` (world/parade/squad_size.gd) |
| `army_squad_geometry.dart` | Replaced by 3D: `Squad` (world/parade/squad.gd), `SquadSize` (world/parade/squad_size.gd) |
| `army_squad_pose.dart` | Replaced by 3D: `Squad` (world/parade/squad.gd), `SquadSize` (world/parade/squad_size.gd) |
| `army_squads_painter.dart` | Replaced by 3D: `Squad` (world/parade/squad.gd), `SquadSize` (world/parade/squad_size.gd) |
| `army_trident.dart` | Replaced by 3D: The army's parade ground is drawn in 3D: `ParadeScene` (world/parade/parade_scene.gd), `ParadeGround` (world/parade/parade_ground.gd). |
| `army_view.dart` | Replaced by 3D: The army's parade ground is drawn in 3D: `ParadeScene` (world/parade/parade_scene.gd), `ParadeGround` (world/parade/parade_ground.gd). |
| `banner_corner.dart` | Replaced by 3D: The army's parade ground is drawn in 3D: `ParadeScene` (world/parade/parade_scene.gd), `ParadeGround` (world/parade/parade_ground.gd). |
| `squad_arrival.dart` | **Missing.** The squads' arrival animation (step 7). |
| `squad_size.dart` | `SquadSize` (world/parade/squad_size.gd) |
| `squad_slots.dart` | Replaced by 3D: The army's parade ground is drawn in 3D: `ParadeScene` (world/parade/parade_scene.gd), `ParadeGround` (world/parade/parade_ground.gd). |

### `lib/presentation/widgets/backdrop/`

| Flutter file | Godot |
| --- | --- |
| `abyss_backdrop.dart` | Replaced by 3D: The menus' and the game's backdrop is the 3D world's ambience: `UnderwaterEnvironment` (world/ambience/underwater_environment.gd), `LightShafts` (world/ambience/light_shafts.gd), `MarineSnow` (world/ambience/marine_snow.gd), `WorldHost` (app/world/world_host.gd). |
| `backdrop_geometry.dart` | Replaced by 3D: The menus' and the game's backdrop is the 3D world's ambience: `UnderwaterEnvironment` (world/ambience/underwater_environment.gd), `LightShafts` (world/ambience/light_shafts.gd), `MarineSnow` (world/ambience/marine_snow.gd), `WorldHost` (app/world/world_host.gd). |
| `backdrop_image.dart` | Replaced by 3D: The menus' and the game's backdrop is the 3D world's ambience: `UnderwaterEnvironment` (world/ambience/underwater_environment.gd), `LightShafts` (world/ambience/light_shafts.gd), `MarineSnow` (world/ambience/marine_snow.gd), `WorldHost` (app/world/world_host.gd). |
| `backdrop_prewarm.dart` | Replaced by 3D: The menus' and the game's backdrop is the 3D world's ambience: `UnderwaterEnvironment` (world/ambience/underwater_environment.gd), `LightShafts` (world/ambience/light_shafts.gd), `MarineSnow` (world/ambience/marine_snow.gd), `WorldHost` (app/world/world_host.gd). |
| `backdrop_raster_cache.dart` | Replaced by 3D: The menus' and the game's backdrop is the 3D world's ambience: `UnderwaterEnvironment` (world/ambience/underwater_environment.gd), `LightShafts` (world/ambience/light_shafts.gd), `MarineSnow` (world/ambience/marine_snow.gd), `WorldHost` (app/world/world_host.gd). |
| `breathing_rays.dart` | Replaced by 3D: The menus' and the game's backdrop is the 3D world's ambience: `UnderwaterEnvironment` (world/ambience/underwater_environment.gd), `LightShafts` (world/ambience/light_shafts.gd), `MarineSnow` (world/ambience/marine_snow.gd), `WorldHost` (app/world/world_host.gd). |
| `marine_snow.dart` | `MarineSnow` (world/ambience/marine_snow.gd) |
| `marine_snow_field.dart` | Replaced by 3D: The menus' and the game's backdrop is the 3D world's ambience: `UnderwaterEnvironment` (world/ambience/underwater_environment.gd), `LightShafts` (world/ambience/light_shafts.gd), `MarineSnow` (world/ambience/marine_snow.gd), `WorldHost` (app/world/world_host.gd). |
| `marine_snow_painter.dart` | Replaced by 3D: The menus' and the game's backdrop is the 3D world's ambience: `UnderwaterEnvironment` (world/ambience/underwater_environment.gd), `LightShafts` (world/ambience/light_shafts.gd), `MarineSnow` (world/ambience/marine_snow.gd), `WorldHost` (app/world/world_host.gd). |

### `lib/presentation/widgets/backdrop/trench/`

| Flutter file | Godot |
| --- | --- |
| `depth_haze.dart` | Replaced by 3D: The menus' and the game's backdrop is the 3D world's ambience: `UnderwaterEnvironment` (world/ambience/underwater_environment.gd), `LightShafts` (world/ambience/light_shafts.gd), `MarineSnow` (world/ambience/marine_snow.gd), `WorldHost` (app/world/world_host.gd). |
| `parallax_drift.dart` | Replaced by 3D: The menus' and the game's backdrop is the 3D world's ambience: `UnderwaterEnvironment` (world/ambience/underwater_environment.gd), `LightShafts` (world/ambience/light_shafts.gd), `MarineSnow` (world/ambience/marine_snow.gd), `WorldHost` (app/world/world_host.gd). |
| `parallax_layer.dart` | Replaced by 3D: The menus' and the game's backdrop is the 3D world's ambience: `UnderwaterEnvironment` (world/ambience/underwater_environment.gd), `LightShafts` (world/ambience/light_shafts.gd), `MarineSnow` (world/ambience/marine_snow.gd), `WorldHost` (app/world/world_host.gd). |
| `trench_backdrop.dart` | Replaced by 3D: The menus' and the game's backdrop is the 3D world's ambience: `UnderwaterEnvironment` (world/ambience/underwater_environment.gd), `LightShafts` (world/ambience/light_shafts.gd), `MarineSnow` (world/ambience/marine_snow.gd), `WorldHost` (app/world/world_host.gd). |
| `trench_ridge_crest.dart` | Replaced by 3D: The menus' and the game's backdrop is the 3D world's ambience: `UnderwaterEnvironment` (world/ambience/underwater_environment.gd), `LightShafts` (world/ambience/light_shafts.gd), `MarineSnow` (world/ambience/marine_snow.gd), `WorldHost` (app/world/world_host.gd). |
| `trench_ridges_painter.dart` | Replaced by 3D: The menus' and the game's backdrop is the 3D world's ambience: `UnderwaterEnvironment` (world/ambience/underwater_environment.gd), `LightShafts` (world/ambience/light_shafts.gd), `MarineSnow` (world/ambience/marine_snow.gd), `WorldHost` (app/world/world_host.gd). |
| `trench_water_painter.dart` | Replaced by 3D: The menus' and the game's backdrop is the 3D world's ambience: `UnderwaterEnvironment` (world/ambience/underwater_environment.gd), `LightShafts` (world/ambience/light_shafts.gd), `MarineSnow` (world/ambience/marine_snow.gd), `WorldHost` (app/world/world_host.gd). |

### `lib/presentation/widgets/base/`

| Flutter file | Godot |
| --- | --- |
| `base_badge.dart` | Replaced by 3D: `PadMarks` (world/base/pad_marks.gd), `PadMark` (world/base/pad_mark.gd) |
| `base_badge_geometry.dart` | Replaced by 3D: `PadMarks` (world/base/pad_marks.gd), `PadMark` (world/base/pad_mark.gd) |
| `base_badges_layer.dart` | Replaced by 3D: `PadMarks` (world/base/pad_marks.gd), `PadMark` (world/base/pad_mark.gd) |
| `base_badges_painter.dart` | Replaced by 3D: `PadMarks` (world/base/pad_marks.gd), `PadMark` (world/base/pad_mark.gd) |
| `base_building_pose.dart` | Replaced by 3D: `BaseBuildings` (world/base/base_buildings.gd) |
| `base_building_semantics.dart` | Replaced by 3D: `BaseBuildings` (world/base/base_buildings.gd) |
| `base_buildings_layer.dart` | Replaced by 3D: `BaseBuildings` (world/base/base_buildings.gd) |
| `base_buildings_painter.dart` | Replaced by 3D: `BaseBuildings` (world/base/base_buildings.gd) |
| `base_cable.dart` | Replaced by 3D: The island is drawn in 3D: `BaseScene` (world/base/base_scene.gd). |
| `base_deck_drawer.dart` | Replaced by 3D: The island is drawn in 3D: `BaseScene` (world/base/base_scene.gd). |
| `base_decor.dart` | Replaced by 3D: The island is drawn in 3D: `BaseScene` (world/base/base_scene.gd). |
| `base_drawing.dart` | Replaced by 3D: The island is drawn in 3D: `BaseScene` (world/base/base_scene.gd). |
| `base_fit.dart` | Replaced by 3D: `OrbitFrame` (world/camera/orbit_frame.gd), `OrbitCamera` (world/camera/orbit_camera.gd) |
| `base_guide_halo.dart` | `GuideRing` (world/guide/guide_ring.gd) (on the pad), aimed by `GuideController` (app/game/guide_controller.gd) |
| `base_hit.dart` | Replaced by 3D: `BasePads` (world/base/base_pads.gd) (`pick`) |
| `base_hud.dart` | `GameHud` (ui/game/game_hud.gd), `BaseBanners` (ui/building/base_banners.gd) |
| `base_island_painter.dart` | Replaced by 3D: The island is drawn in 3D: `BaseScene` (world/base/base_scene.gd). |
| `base_label_text.dart` | Replaced by 3D: `PadLevelLabel` (world/base/pad_level_label.gd) |
| `base_layers.dart` | Replaced by 3D: The island is drawn in 3D: `BaseScene` (world/base/base_scene.gd). |
| `base_layout.dart` | Replaced by 3D: The island is drawn in 3D: `BaseScene` (world/base/base_scene.gd). |
| `base_marker_drawer.dart` | Replaced by 3D: `PadMarker` (world/base/pad_marker.gd) |
| `base_pad_drawer.dart` | Replaced by 3D: `BasePads` (world/base/base_pads.gd) |
| `base_pad_geometry.dart` | Replaced by 3D: `BasePads` (world/base/base_pads.gd) |
| `base_pad_slab.dart` | Replaced by 3D: `BasePads` (world/base/base_pads.gd) |
| `base_pad_tier.dart` | Replaced by 3D: `BasePads` (world/base/base_pads.gd) |
| `base_plaque_drawer.dart` | Replaced by 3D: The island is drawn in 3D: `BaseScene` (world/base/base_scene.gd). |
| `base_plateau.dart` | Replaced by 3D: The island is drawn in 3D: `BaseScene` (world/base/base_scene.gd). |
| `base_rampart.dart` | Replaced by 3D: The rampart of `BaseScene` (world/base/base_scene.gd) (`BuildingTier.rampart_of`). |
| `base_rampart_drawer.dart` | Replaced by 3D: The rampart of `BaseScene` (world/base/base_scene.gd) (`BuildingTier.rampart_of`). |
| `base_rampart_painter.dart` | Replaced by 3D: The rampart of `BaseScene` (world/base/base_scene.gd) (`BuildingTier.rampart_of`). |
| `base_rampart_segment.dart` | Replaced by 3D: The rampart of `BaseScene` (world/base/base_scene.gd) (`BuildingTier.rampart_of`). |
| `base_slot.dart` | Replaced by 3D: `BasePads` (world/base/base_pads.gd) |
| `base_slot_halo.dart` | `GuideRing` (world/guide/guide_ring.gd) (on the pad), aimed by `GuideController` (app/game/guide_controller.gd) |
| `base_slot_projection.dart` | Replaced by 3D: `BasePads` (world/base/base_pads.gd) |
| `base_snapshot.dart` | Replaced by 3D: The island is drawn in 3D: `BaseScene` (world/base/base_scene.gd). |
| `base_spire.dart` | Replaced by 3D: The island is drawn in 3D: `BaseScene` (world/base/base_scene.gd). |
| `base_sprite_paints.dart` | Replaced by 3D: The island is drawn in 3D: `BaseScene` (world/base/base_scene.gd). |
| `base_sprites.dart` | Replaced by 3D: The island is drawn in 3D: `BaseScene` (world/base/base_scene.gd). |
| `base_view.dart` | Replaced by 3D: The island is drawn in 3D: `BaseScene` (world/base/base_scene.gd). |
| `base_walkway_drawer.dart` | Replaced by 3D: The island is drawn in 3D: `BaseScene` (world/base/base_scene.gd). |
| `base_walkways.dart` | Replaced by 3D: The island is drawn in 3D: `BaseScene` (world/base/base_scene.gd). |

### `lib/presentation/widgets/building/`

| Flutter file | Godot |
| --- | --- |
| `base_shield_badge.dart` | `ShieldBadge` (ui/building/shield_badge.gd) |
| `building_card.dart` | `BuildingCard` (ui/building/building_card.gd) |
| `building_detail_sheet.dart` | `BuildingSheet` (ui/building/building_sheet.gd) |
| `building_icon.dart` | `BuildingCard` (ui/building/building_card.gd) (a `Portrait` until step 7) |
| `coral_citadel_info_section.dart` | `CitadelSection` (ui/building/citadel_section.gd) |
| `degraded_badge.dart` | `DegradedBadge` (ui/building/degraded_badge.gd) |
| `lively_building_icon.dart` | `BaseMotion` (world/base/base_motion.gd) (the buildings move in 3D) |
| `upgrade_section.dart` | `UpgradeSection` (ui/building/upgrade_section.gd) |
| `worksite_badge.dart` | `WorksiteBadge` (ui/building/worksite_badge.gd) |

### `lib/presentation/widgets/common/`

| Flutter file | Godot |
| --- | --- |
| `atlas_mesh.dart` | Not needed: Flutter's raster and sprite plumbing; Godot imports and draws its textures. |
| `back_to_front.dart` | Not needed: Flutter's raster and sprite plumbing; Godot imports and draws its textures. |
| `background_tasks.dart` | Not needed: Flutter's raster and sprite plumbing; Godot imports and draws its textures. |
| `copied_image_shader.dart` | Not needed: Flutter's raster and sprite plumbing; Godot imports and draws its textures. |
| `difficulty_picker.dart` | `DifficultyPicker` (ui/new_game/difficulty_picker.gd) |
| `faction_count_picker.dart` | `FactionCountPicker` (ui/new_game/faction_count_picker.gd) |
| `fixed_rect_clipper.dart` | Not needed: Flutter's raster and sprite plumbing; Godot imports and draws its textures. |
| `game_bottom_bar.dart` | `GameTabBar` (ui/game/game_tab_bar.gd) |
| `game_status_bars.dart` | `GameStatusBars` (ui/game/game_status_bars.gd) |
| `greyscale_bitmap.dart` | `Greyscale` (ui/common/greyscale.gd) |
| `guide_settings.dart` | `GuideSettings` (ui/settings/guide_settings.gd) |
| `illustrated_card.dart` | `IllustratedCard` (ui/common/illustrated_card.gd) |
| `kept_rasters.dart` | Not needed: Flutter's raster and sprite plumbing; Godot imports and draws its textures. |
| `labeled_switch.dart` | `LabeledSwitch` (ui/common/labeled_switch.gd) |
| `language_dialog.dart` | `LanguageDialog` (ui/settings/language_dialog.gd) |
| `language_picker.dart` | `LanguagePicker` (ui/settings/language_picker.gd) |
| `lore_text.dart` | `LoreText` (ui/common/lore_text.gd) |
| `notice_banner.dart` | `NoticeBanner` (ui/common/notice_banner.gd) |
| `painted_raster.dart` | Not needed: Flutter's raster and sprite plumbing; Godot imports and draws its textures. |
| `raster_paint.dart` | Not needed: Flutter's raster and sprite plumbing; Godot imports and draws its textures. |
| `raster_svg.dart` | `UiIcon` (ui/common/ui_icon.gd) |
| `recorded_pictures.dart` | Not needed: Flutter's raster and sprite plumbing; Godot imports and draws its textures. |
| `replay_export_dialog.dart` | `ReplayExportDialog` (ui/export/replay_export_dialog.gd) |
| `run_concurrently.dart` | Not needed: Flutter's raster and sprite plumbing; Godot imports and draws its textures. |
| `segmented_bar.dart` | `SegmentedBar` (ui/common/segmented_bar.gd) |
| `settings_dialog.dart` | `SettingsDialog` (ui/settings/settings_dialog.gd) |
| `sheet_drag_handle.dart` | `SheetDragHandle` (ui/common/sheet_drag_handle.gd) |
| `span_cover.dart` | Not needed: Flutter's raster and sprite plumbing; Godot imports and draws its textures. |
| `sprite_atlas.dart` | Not needed: Flutter's raster and sprite plumbing; Godot imports and draws its textures. |
| `status_pill.dart` | `StatusPill` (ui/common/status_pill.gd) |
| `svg_raster_cache.dart` | Not needed: Flutter's raster and sprite plumbing; Godot imports and draws its textures. |
| `tab_placeholder.dart` | `TabPlaceholder` (ui/common/tab_placeholder.gd) |
| `threat_banner.dart` | `ThreatBanner` (ui/common/threat_banner.gd) |

### `lib/presentation/widgets/event/`

| Flutter file | Godot |
| --- | --- |
| `event_card.dart` | `EventCard` (ui/event/event_card.gd) |
| `event_card_data.dart` | `EventCardData` (ui/event/event_card_data.gd) |
| `event_card_texts.dart` | `EventCardTexts` (ui/event/event_card_texts.gd) |
| `event_choice.dart` | `EventChoice` (ui/event/event_choice.gd) |
| `event_pending_warning.dart` | `EventPendingWarning` (ui/event/event_pending_warning.gd) |
| `event_status_bar.dart` | `EventStatusBar` (ui/event/event_status_bar.gd) |

### `lib/presentation/widgets/faction/`

| Flutter file | Godot |
| --- | --- |
| `base_intel_report.dart` | `BaseIntelReport` (ui/faction/base_intel_report.gd) |
| `faction_base_colors.dart` | `FactionIdentity` (ui/faction/faction_identity.gd) |
| `faction_base_sheet.dart` | `FactionBaseSheet` (ui/faction/faction_base_sheet.gd) |
| `faction_emblem.dart` | `FactionEmblem` (ui/faction/faction_emblem.gd) |
| `faction_identity.dart` | `FactionIdentity` (ui/faction/faction_identity.gd) |
| `faction_ranking_sheet.dart` | `FactionRankingSheet` (ui/faction/faction_ranking_sheet.gd) |
| `faction_standing_tile.dart` | `FactionStandingTile` (ui/faction/faction_standing_tile.gd) |

### `lib/presentation/widgets/fight/`

| Flutter file | Godot |
| --- | --- |
| `army_selection_actions.dart` | `ArmySelectionActions` (ui/fight/army_selection_actions.gd) |
| `assault_chance_gauge.dart` | `AssaultChanceGauge` (ui/assault/assault_chance_gauge.gd) |
| `assault_check_row.dart` | `AssaultCheckRow` (ui/assault/assault_check_row.gd) |
| `assault_damage_card.dart` | `AssaultDamageCard` (ui/assault/assault_damage_card.gd) |
| `assault_kernel_card.dart` | `AssaultKernelCard` (ui/assault/assault_kernel_card.gd) |
| `assault_plan_panel.dart` | `AssaultPlanPanel` (ui/assault/assault_plan_panel.gd) |
| `fight_kill_count.dart` | `FightKillCount` (ui/fight/fight_kill_count.gd) |
| `fight_loot_card.dart` | `FightLootCard` (ui/fight/fight_loot_card.gd) |
| `fight_report_card.dart` | `FightReportCard` (ui/fight/fight_report_card.gd) |
| `fight_result_banner.dart` | `FightResultBanner` (ui/fight/fight_result_banner.gd) |
| `fight_turn_list.dart` | `FightTurnList` (ui/fight/fight_turn_list.gd) |
| `fight_unit_accounting.dart` | `FightUnitAccounting` (ui/fight/fight_unit_accounting.gd) |
| `monster_family_traits.dart` | `MonsterFamilyTraits` (ui/fight/monster_family_traits.gd) |
| `monster_preview.dart` | `MonsterPreview` (ui/fight/monster_preview.gd) |
| `selection_summary_card.dart` | `SelectionSummaryCard` (ui/fight/selection_summary_card.gd) |
| `unit_quantity_row.dart` | `UnitQuantityRow` (ui/unit/unit_quantity_row.gd) |

### `lib/presentation/widgets/game_over/`

| Flutter file | Godot |
| --- | --- |
| `defeat_cause_card.dart` | `DefeatCauseCard` (ui/game_over/defeat_cause_card.gd) |
| `game_statistics_card.dart` | `GameStatisticsCard` (ui/game_over/game_statistics_card.gd) |

### `lib/presentation/widgets/guide/`

| Flutter file | Godot |
| --- | --- |
| `guide_bubble.dart` | `GuideBubble` (ui/guide/guide_bubble.gd) |
| `guide_card_halo.dart` | `GuideCardHalo` (ui/guide/guide_card_halo.gd) |
| `guide_cell_halo.dart` | `MapGuide` (world/guide/map_guide.gd), `GuideRing` (world/guide/guide_ring.gd) (a ring on the floor of the map) |
| `guide_halo.dart` | `GuideHalo` (ui/common/guide_halo.gd) |
| `guide_halo_painter.dart` | `GuideHalo` (ui/common/guide_halo.gd) (a themed pulsing rim) |
| `guide_scope.dart` | `GuideScope` (ui/guide/guide_scope.gd) |

### `lib/presentation/widgets/history/`

| Flutter file | Godot |
| --- | --- |
| `history_assault_launcher.dart` | `HistoryReports` (ui/history/history_reports.gd) |
| `history_entry_card.dart` | `HistoryEntryCard` (ui/history/history_entry_card.gd) |
| `history_fight_launcher.dart` | `HistoryReports` (ui/history/history_reports.gd) |
| `history_filter.dart` | `HistoryFilter` (ui/history/history_filter.gd) |
| `history_filter_chips.dart` | `HistoryFilterChips` (ui/history/history_filter_chips.gd) |
| `history_raid_launcher.dart` | `HistoryReports` (ui/history/history_reports.gd) |
| `history_sheet.dart` | `HistorySheet` (ui/history/history_sheet.gd) |
| `history_sheet_body.dart` | `HistorySheet` (ui/history/history_sheet.gd) |
| `history_volcano_launcher.dart` | `HistoryReports` (ui/history/history_reports.gd) |

### `lib/presentation/widgets/leviathan/`

| Flutter file | Godot |
| --- | --- |
| `leviathan_due_warning.dart` | `LeviathanDueWarning` (ui/threat/leviathan_due_warning.gd) |
| `leviathan_status_bar.dart` | `LeviathanStatusBar` (ui/threat/leviathan_status_bar.gd) |

### `lib/presentation/widgets/map/`

| Flutter file | Godot |
| --- | --- |
| `cell_info_sheet.dart` | `CellInfoSheet` (ui/map/cell_info_sheet.gd) |
| `exploration_sheet.dart` | `ExplorationSheet` (ui/map/exploration_sheet.gd) |
| `game_map_view.dart` | `MapScene` (world/map/map_scene.gd), `MapTab` (ui/map/map_tab.gd) |
| `level_selector.dart` | `LevelSelector` (ui/map/level_selector.gd) |
| `living_creatures.dart` | **Missing.** The creatures drawn alive on the map (step 7). |
| `map_cell_at.dart` | `MapGrid` (world/map/map_grid.gd), `MapPick` (world/map/map_pick.gd) |
| `map_cell_motion.dart` | **Missing.** The cells' own motion (step 7). |
| `map_cell_size.dart` | `MapGrid` (world/map/map_grid.gd), `MapPick` (world/map/map_pick.gd) |
| `map_cell_visual.dart` | `MapContents` (world/map/map_contents.gd), `MapLook` (world/map/map_look.gd) (3D stand-ins on the cells) |
| `map_centring.dart` | `MapCamera` (world/map/map_camera.gd), `MapRig` (world/map/map_rig.gd) |
| `map_content_drawer.dart` | `MapContents` (world/map/map_contents.gd), `MapLook` (world/map/map_look.gd) (3D stand-ins on the cells) |
| `map_content_fade.dart` | `MapContents` (world/map/map_contents.gd), `MapLook` (world/map/map_look.gd) (3D stand-ins on the cells) |
| `map_content_spot.dart` | `MapContents` (world/map/map_contents.gd), `MapLook` (world/map/map_look.gd) (3D stand-ins on the cells) |
| `map_creature_sheets.dart` | **Missing.** The creatures drawn alive on the map (step 7). |
| `map_flat_contents.dart` | `MapContents` (world/map/map_contents.gd), `MapLook` (world/map/map_look.gd) (3D stand-ins on the cells) |
| `map_floor.dart` | `MapTiles` (world/map/map_tiles.gd) |
| `map_floor_sprites.dart` | `MapTiles` (world/map/map_tiles.gd) |
| `map_floor_tiles.dart` | `MapTiles` (world/map/map_tiles.gd) |
| `map_fog.dart` | `MapTiles` (world/map/map_tiles.gd) (the fog is the dark tiles under it) |
| `map_glow_sprites.dart` | `MapContents` (world/map/map_contents.gd), `MapLook` (world/map/map_look.gd) (3D stand-ins on the cells) |
| `map_layers.dart` | `MapScene` (world/map/map_scene.gd) |
| `map_level_info.dart` | `MapLevelState` (world/map/map_level_state.gd) |
| `map_painter.dart` | `MapScene` (world/map/map_scene.gd) |
| `map_projection.dart` | `MapCamera` (world/map/map_camera.gd), `MapRig` (world/map/map_rig.gd) |
| `map_scatter.dart` | `MarineSnow` (world/ambience/marine_snow.gd) (the world's ambience) |
| `map_snow_layer.dart` | `MarineSnow` (world/ambience/marine_snow.gd) (the world's ambience) |
| `map_snow_painter.dart` | `MarineSnow` (world/ambience/marine_snow.gd) (the world's ambience) |
| `map_sprites.dart` | `MapContents` (world/map/map_contents.gd), `MapLook` (world/map/map_look.gd) (3D stand-ins on the cells) |
| `map_sprites_loading.dart` | `MapContents` (world/map/map_contents.gd), `MapLook` (world/map/map_look.gd) (3D stand-ins on the cells) |
| `map_standing_fade.dart` | `MapContents` (world/map/map_contents.gd), `MapPick` (world/map/map_pick.gd) (what stands on a cell, picked in 3D) |
| `map_standing_hit.dart` | `MapContents` (world/map/map_contents.gd), `MapPick` (world/map/map_pick.gd) (what stands on a cell, picked in 3D) |
| `map_standing_order.dart` | `MapContents` (world/map/map_contents.gd), `MapPick` (world/map/map_pick.gd) (what stands on a cell, picked in 3D) |
| `map_standing_painter.dart` | `MapContents` (world/map/map_contents.gd), `MapPick` (world/map/map_pick.gd) (what stands on a cell, picked in 3D) |
| `map_standing_sprite.dart` | `MapContents` (world/map/map_contents.gd), `MapPick` (world/map/map_pick.gd) (what stands on a cell, picked in 3D) |
| `map_view_fit.dart` | `MapCamera` (world/map/map_camera.gd), `MapRig` (world/map/map_rig.gd) |
| `map_viewport.dart` | `MapCamera` (world/map/map_camera.gd), `MapRig` (world/map/map_rig.gd) |
| `map_visuals_builder.dart` | `MapContents` (world/map/map_contents.gd), `MapLook` (world/map/map_look.gd) (3D stand-ins on the cells) |
| `monster_lair_sheet.dart` | `MonsterLairSheet` (ui/fight/monster_lair_sheet.gd) |
| `post_defence_panel.dart` | `PostDefencePanel` (ui/post/post_defence_panel.gd) |
| `rival_post_sheet.dart` | `RivalPostSheet` (ui/post/rival_post_sheet.gd) |
| `scout_origin.dart` | `ScoutOrigin` (world/map/scout_origin.gd) |
| `scout_token_layer.dart` | `MapScouts` (world/map/map_scouts.gd), `ScoutToken` (world/map/scout_token.gd) |
| `sheet_info_row.dart` | `SheetInfoRow` (ui/map/sheet_info_row.gd) |
| `sheet_notice.dart` | `SheetNotice` (ui/map/sheet_notice.gd) |
| `transition_base_captured_section.dart` | `TransitionBaseCapturedSection` (ui/post/transition_base_captured_section.gd) |
| `transition_base_sheet.dart` | `TransitionBaseSheet` (ui/post/transition_base_sheet.gd) |
| `transition_base_uncaptured_section.dart` | `TransitionBaseUncapturedSection` (ui/post/transition_base_uncaptured_section.gd) |
| `treasure_sheet.dart` | `TreasureSheet` (ui/map/treasure_sheet.gd) |
| `viewport_cover.dart` | `MapCamera` (world/map/map_camera.gd), `MapRig` (world/map/map_rig.gd) |
| `volcanic_kernel_sheet.dart` | `VolcanicKernelSheet` (ui/kernel/volcanic_kernel_sheet.gd) |

### `lib/presentation/widgets/map/decor/`

| Flutter file | Godot |
| --- | --- |
| `decor_keep_out.dart` | **Missing.** The scattered decor of the map's floor (step 7). |
| `decor_kind.dart` | **Missing.** The scattered decor of the map's floor (step 7). |
| `decor_scatter.dart` | **Missing.** The scattered decor of the map's floor (step 7). |
| `map_decor.dart` | **Missing.** The scattered decor of the map's floor (step 7). |
| `map_decor_cells.dart` | **Missing.** The scattered decor of the map's floor (step 7). |
| `map_decor_drawer.dart` | **Missing.** The scattered decor of the map's floor (step 7). |

### `lib/presentation/widgets/map/effects/`

| Flutter file | Godot |
| --- | --- |
| `map_effect.dart` | **Missing.** The strike, siege and fog-lift animations of the map (step 7). |
| `map_effect_painter.dart` | **Missing.** The strike, siege and fog-lift animations of the map (step 7). |
| `map_effects.dart` | **Missing.** The strike, siege and fog-lift animations of the map (step 7). |
| `map_effects_layer.dart` | **Missing.** The strike, siege and fog-lift animations of the map (step 7). |
| `map_jolt.dart` | **Missing.** The strike, siege and fog-lift animations of the map (step 7). |

### `lib/presentation/widgets/map/effects/story/`

| Flutter file | Godot |
| --- | --- |
| `fog_lift_run.dart` | **Missing.** The strike, siege and fog-lift animations of the map (step 7). |
| `map_fog_lift.dart` | **Missing.** The strike, siege and fog-lift animations of the map (step 7). |
| `map_siege.dart` | **Missing.** The strike, siege and fog-lift animations of the map (step 7). |
| `map_siege_run.dart` | **Missing.** The strike, siege and fog-lift animations of the map (step 7). |
| `siege_floor.dart` | **Missing.** The strike, siege and fog-lift animations of the map (step 7). |
| `siege_geometry.dart` | **Missing.** The strike, siege and fog-lift animations of the map (step 7). |
| `siege_timeline.dart` | **Missing.** The strike, siege and fog-lift animations of the map (step 7). |

### `lib/presentation/widgets/map/effects/strike/`

| Flutter file | Godot |
| --- | --- |
| `fight_pace.dart` | **Missing.** The strike, siege and fog-lift animations of the map (step 7). |
| `map_strike.dart` | **Missing.** The strike, siege and fog-lift animations of the map (step 7). |
| `map_strike_run.dart` | **Missing.** The strike, siege and fog-lift animations of the map (step 7). |
| `strike_geometry.dart` | **Missing.** The strike, siege and fog-lift animations of the map (step 7). |
| `strike_lead.dart` | **Missing.** The strike, siege and fog-lift animations of the map (step 7). |
| `strike_marks.dart` | **Missing.** The strike, siege and fog-lift animations of the map (step 7). |
| `strike_round.dart` | **Missing.** The strike, siege and fog-lift animations of the map (step 7). |
| `strike_timeline.dart` | **Missing.** The strike, siege and fog-lift animations of the map (step 7). |

### `lib/presentation/widgets/map/slab/`

| Flutter file | Godot |
| --- | --- |
| `iso_slab.dart` | Replaced by 3D: The isometric slab of the level is the floor of `MapTiles` (world/map/map_tiles.gd). |
| `iso_slab_painter.dart` | Replaced by 3D: The isometric slab of the level is the floor of `MapTiles` (world/map/map_tiles.gd). |
| `map_slab_layer.dart` | Replaced by 3D: The isometric slab of the level is the floor of `MapTiles` (world/map/map_tiles.gd). |
| `map_slab_painter.dart` | Replaced by 3D: The isometric slab of the level is the floor of `MapTiles` (world/map/map_tiles.gd). |
| `slab_face.dart` | Replaced by 3D: The isometric slab of the level is the floor of `MapTiles` (world/map/map_tiles.gd). |
| `slab_rock.dart` | Replaced by 3D: The isometric slab of the level is the floor of `MapTiles` (world/map/map_tiles.gd). |
| `slab_rock_chunk.dart` | Replaced by 3D: The isometric slab of the level is the floor of `MapTiles` (world/map/map_tiles.gd). |
| `slab_rock_chunks.dart` | Replaced by 3D: The isometric slab of the level is the floor of `MapTiles` (world/map/map_tiles.gd). |
| `slab_strip.dart` | Replaced by 3D: The isometric slab of the level is the floor of `MapTiles` (world/map/map_tiles.gd). |

### `lib/presentation/widgets/map/token/`

| Flutter file | Godot |
| --- | --- |
| `map_token_drawer.dart` | Replaced by 3D: `ScoutToken` (world/map/scout_token.gd), `MapScouts` (world/map/map_scouts.gd) |
| `map_token_trip.dart` | Replaced by 3D: `ScoutToken` (world/map/scout_token.gd), `MapScouts` (world/map/map_scouts.gd) |
| `map_tokens_painter.dart` | Replaced by 3D: `ScoutToken` (world/map/scout_token.gd), `MapScouts` (world/map/map_scouts.gd) |

### `lib/presentation/widgets/menu/`

| Flutter file | Godot |
| --- | --- |
| `beta_notice.dart` | `BetaNotice` (ui/menu/beta_notice.gd) |
| `count_badge.dart` | `CountBadge` (ui/common/count_badge.gd) |
| `glow_title.dart` | `GlowTitle` (ui/menu/glow_title.gd) |
| `menu_button.dart` | `MenuEntry` (ui/menu/menu_entry.gd) |
| `menu_layout.dart` | `MenuLayout` (ui/menu/menu_layout.gd) |
| `menu_settings_button.dart` | `MenuSettingsButton` (ui/menu/menu_settings_button.gd) |

### `lib/presentation/widgets/objective/`

| Flutter file | Godot |
| --- | --- |
| `objective_banner.dart` | `ObjectiveBanner` (ui/objective/objective_banner.gd) |
| `objective_row.dart` | `ObjectiveRow` (ui/objective/objective_row.gd) |
| `objective_section_header.dart` | `ObjectiveSectionHeader` (ui/objective/objective_section_header.gd) |
| `objectives_sheet.dart` | `ObjectivesSheet` (ui/objective/objectives_sheet.gd) |

### `lib/presentation/widgets/opening/`

| Flutter file | Godot |
| --- | --- |
| `opening_story.dart` | `OpeningStory` (ui/opening/opening_story.gd) |
| `story_card.dart` | `StoryCard` (ui/opening/story_card.gd) |
| `story_page.dart` | `StoryPage` (ui/opening/story_page.gd) |
| `story_pager.dart` | `StoryPager` (ui/opening/story_pager.gd) |

### `lib/presentation/widgets/raid/`

| Flutter file | Godot |
| --- | --- |
| `noise_cost_row.dart` | `NoiseCostRow` (ui/threat/noise_cost_row.gd) |
| `raid_due_warning.dart` | `RaidDueWarning` (ui/threat/raid_due_warning.gd) |
| `raid_status_bar.dart` | `RaidStatusBar` (ui/threat/raid_status_bar.gd) |
| `raid_turn_section.dart` | `RaidTurnSection` (ui/threat/raid_turn_section.gd) |

### `lib/presentation/widgets/resource/`

| Flutter file | Godot |
| --- | --- |
| `animated_resource_amount.dart` | `AnimatedAmount` (ui/resource/animated_amount.gd) |
| `resource_amount_strip.dart` | `ResourceAmountStrip` (ui/resource/resource_amount_strip.gd) |
| `resource_bar.dart` | `ResourceBar` (ui/resource/resource_bar.gd) |
| `resource_bar_item.dart` | `ResourceBarItem` (ui/resource/resource_bar_item.gd) |
| `resource_detail_sheet.dart` | `ResourceDetailSheet` (ui/resource/resource_detail_sheet.gd) |
| `resource_gain_dialog.dart` | `ResourceGainDialog` (ui/resource/resource_gain_dialog.gd) |
| `resource_gains_row.dart` | `ResourceGainsRow` (ui/resource/resource_gains_row.gd) |
| `resource_icon.dart` | `ResourceIcon` (ui/common/resource_icon.gd) |

### `lib/presentation/widgets/save/`

| Flutter file | Godot |
| --- | --- |
| `confirm_save_deletion.dart` | `SaveDeletionDialog` (ui/save/save_deletion_dialog.gd) |
| `empty_saves.dart` | `EmptySaves` (ui/save/empty_saves.gd) |
| `save_card.dart` | `SaveCard` (ui/save/save_card.gd) |
| `save_card_details.dart` | `SaveCardDetails` (ui/save/save_card_details.gd) |
| `save_card_menu.dart` | `SaveCardMenu` (ui/save/save_card_menu.gd) |
| `save_list.dart` | `SaveList` (ui/save/save_list.gd) |
| `save_section_header.dart` | `SaveSectionHeader` (ui/save/save_section_header.gd) |

### `lib/presentation/widgets/tech/`

| Flutter file | Godot |
| --- | --- |
| `dashed_ring_painter.dart` | `TechBranchMedallion` (ui/tech/tech_branch_medallion.gd) (a ring drawn by the theme) |
| `tech_branch_medallion.dart` | `TechBranchMedallion` (ui/tech/tech_branch_medallion.gd) |
| `tech_choice_row.dart` | `TechChoiceRow` (ui/tech/tech_choice_row.gd) |
| `tech_cost_row.dart` | `TechCostRow` (ui/tech/tech_cost_row.gd) |
| `tech_node_widget.dart` | `TechNode` (ui/tech/tech_node.gd) |
| `tech_option_card.dart` | `TechOptionCard` (ui/tech/tech_option_card.gd) |
| `tech_reef.dart` | `TechTreeView` (ui/tech/tech_tree_view.gd), `TechLink` (ui/tech/tech_link.gd) (the tree of medallions, drawn with controls) |
| `tech_reef_geometry.dart` | `TechTreeView` (ui/tech/tech_tree_view.gd), `TechLink` (ui/tech/tech_link.gd) (the tree of medallions, drawn with controls) |
| `tech_reef_painter.dart` | `TechTreeView` (ui/tech/tech_tree_view.gd), `TechLink` (ui/tech/tech_link.gd) (the tree of medallions, drawn with controls) |
| `tech_target.dart` | `TechTarget` (ui/tech/tech_target.gd) |
| `tech_target_header.dart` | `TechTargetHeader` (ui/tech/tech_target_header.gd) |
| `tech_target_panel.dart` | `TechTargetPanel` (ui/tech/tech_target_panel.gd) |
| `tech_tree_view.dart` | `TechTreeView` (ui/tech/tech_tree_view.gd) |

### `lib/presentation/widgets/tip/`

| Flutter file | Godot |
| --- | --- |
| `tip_card.dart` | `TipCard` (ui/tip/tip_card.gd) |
| `tip_guide.dart` | `TipGuide` (ui/tip/tip_guide.gd) |
| `tip_presenter.dart` | `TipPresenter` (ui/tip/tip_presenter.gd) |
| `tip_stack.dart` | `TipStack` (ui/tip/tip_stack.gd) |

### `lib/presentation/widgets/turn/`

| Flutter file | Godot |
| --- | --- |
| `attack_report_lines.dart` | `AttackReportLines` (ui/faction/attack_report_lines.gd) |
| `attack_turn_section.dart` | `AttackTurnSection` (ui/faction/attack_turn_section.gd) |
| `event_turn_section.dart` | `EventTurnSection` (ui/event/event_turn_section.gd) |
| `exploration_summary_section.dart` | `ExplorationTurnSection` (ui/turn/exploration_turn_section.gd) |
| `objective_turn_section.dart` | `ObjectiveTurnSection` (ui/turn/objective_turn_section.gd) |
| `resource_change_line.dart` | `ResourceChangeLine` (ui/turn/resource_change_line.gd) |
| `story_skip_button.dart` | **Missing.** The skip of the turn story (step 7). |
| `summary_line.dart` | `SummaryLine` (ui/turn/summary_line.gd) |
| `turn_confirmation_dialog.dart` | `TurnConfirmation` (ui/turn/turn_confirmation.gd) |
| `turn_loss_sections.dart` | `TurnLosses` (ui/turn/turn_losses.gd), `LossSection` (ui/turn/loss_section.gd) |
| `turn_summary_dialog.dart` | `TurnSummary` (ui/turn/turn_summary.gd), `SummarySections` (ui/turn/summary_sections.gd) |
| `undefended_post_warning.dart` | `UndefendedPostWarning` (ui/turn/undefended_post_warning.gd) |

### `lib/presentation/widgets/unit/`

| Flutter file | Godot |
| --- | --- |
| `recruitment_section.dart` | `RecruitmentSection` (ui/unit/recruitment_section.gd) |
| `unit_card.dart` | `UnitCard` (ui/unit/unit_card.gd) |
| `unit_count_panel.dart` | `UnitCountPanel` (ui/unit/unit_count_panel.gd) |
| `unit_count_row.dart` | `UnitCountRow` (ui/unit/unit_count_row.gd) |
| `unit_detail_sheet.dart` | `UnitSheet` (ui/unit/unit_sheet.gd) |
| `unit_icon.dart` | `UnitPortrait` (ui/unit/unit_portrait.gd) (a `Portrait` until step 7) |
| `unit_picker_dialog.dart` | `UnitPickerDialog` (ui/unit/unit_picker_dialog.gd) |
| `unit_transfer_dialog.dart` | `UnitTransferDialog` (ui/unit/unit_transfer_dialog.gd) |

### `lib/presentation/widgets/volcano/`

| Flutter file | Godot |
| --- | --- |
| `kernel_garrison_panel.dart` | `KernelGarrisonPanel` (ui/kernel/kernel_garrison_panel.gd) |
| `volcano_due_warning.dart` | `VolcanoDueWarning` (ui/threat/volcano_due_warning.gd) |
| `volcano_status_bar.dart` | `VolcanoStatusBar` (ui/threat/volcano_status_bar.gd) |
| `volcano_turn_section.dart` | `VolcanoTurnSection` (ui/threat/volcano_turn_section.gd) |

### `lib/presentation/widgets/warm_up/`

| Flutter file | Godot |
| --- | --- |
| `game_warm_up.dart` | Not needed: Pre-warms Flutter's raster caches; Godot imports its textures. |
| `greyable_icon_paths.dart` | Not needed: Pre-warms Flutter's raster caches; Godot imports its textures. |
| `warm_up_layer.dart` | Not needed: Pre-warms Flutter's raster caches; Godot imports its textures. |
