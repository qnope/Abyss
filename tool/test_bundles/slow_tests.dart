/// About how many seconds the slowest test files take in a bundle, with
/// the other bundles running alongside (measured, with and without
/// coverage): they weigh on the bundles' balance. Any other file takes
/// about [otherTestSeconds].
library;

/// About how many seconds a test file missing from [slowTestSeconds] takes.
const double otherTestSeconds = 0.25;

/// About how many seconds each test file taking 2 seconds or more takes.
const Map<String, double> slowTestSeconds = {
  'domain/faction/faction_race_test.dart': 38.5,
  'svg_assets_test.dart': 8.0,
  'assets/svg_backgrounds_test.dart': 6.0,
  'domain/faction/faction_play_test.dart': 6.0,
  'domain/faction/faction_attack_play_test.dart': 5.5,
  'presentation/screens/game/game_screen_rival_fight_flow_test.dart': 5.0,
  'presentation/widgets/warm_up/game_warm_up_test.dart': 5.0,
  'presentation/screens/menu/new_game_screen_test.dart': 4.0,
  'presentation/screens/game/game_screen_transition_fight_flow_test.dart': 3.5,
  'presentation/screens/menu/new_game_opening_test.dart': 3.5,
  'presentation/screens/game/game_screen_fight_flow_test.dart': 3.5,
  'presentation/widgets/common/raster_svg_test.dart': 3.0,
  'presentation/screens/game/game_screen_transition_actions_test.dart': 3.0,
  'presentation/widgets/backdrop/backdrop_image_test.dart': 3.0,
  'presentation/screens/game/game_screen_test.dart': 3.0,
  'presentation/screens/game/game_screen_army_test.dart': 3.0,
  'presentation/widgets/base/base_view_island_test.dart': 3.0,
  'presentation/widgets/army/army_view_test.dart': 2.5,
  'presentation/screens/game/fight/army_selection_screen_test.dart': 2.5,
  'presentation/screens/game/game_screen_turn_flow_test.dart': 2.5,
  'presentation/screens/game/game_screen_story_test.dart': 2.5,
  'presentation/screens/game/game_screen_guide_test.dart': 2.5,
  'presentation/widgets/army/army_view_layers_test.dart': 2.0,
  'presentation/screens/game/game_screen_consumption_test.dart': 2.0,
  'presentation/screens/game/game_screen_faction_actions_test.dart': 2.0,
  'presentation/screens/game/game_screen_settings_test.dart': 2.0,
};
