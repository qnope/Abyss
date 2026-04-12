import 'package:flutter_svg/flutter_svg.dart';

const _svgAssets = [
  'assets/icons/terrain/plain.svg',
  'assets/icons/terrain/volcanic_kernel.svg',
  'assets/icons/map_content/resource_bonus.svg',
  'assets/icons/map_content/ruins.svg',
  'assets/icons/map_content/player_base.svg',
  'assets/icons/map_content/monster_easy.svg',
  'assets/icons/map_content/monster_medium.svg',
  'assets/icons/map_content/monster_hard.svg',
  'assets/icons/map_content/faction_neutral.svg',
  'assets/icons/map_content/faction_hostile.svg',
  'assets/icons/resources/energy.svg',
  'assets/icons/resources/coral.svg',
  'assets/icons/resources/ore.svg',
  'assets/icons/resources/algae.svg',
  'assets/icons/resources/pearl.svg',
  'assets/icons/buildings/headquarters.svg',
  'assets/icons/buildings/barracks.svg',
  'assets/icons/buildings/laboratory.svg',
  'assets/icons/buildings/coral_mine.svg',
  'assets/icons/buildings/descent_module.svg',
  'assets/icons/buildings/pressure_capsule.svg',
  'assets/icons/buildings/algae_farm.svg',
  'assets/icons/buildings/solar_panel.svg',
  'assets/icons/buildings/coral_citadel.svg',
  'assets/icons/buildings/ore_extractor.svg',
  'assets/icons/units/guardian.svg',
  'assets/icons/units/saboteur.svg',
  'assets/icons/units/siphoner.svg',
  'assets/icons/units/abyss_admiral.svg',
  'assets/icons/units/harpoonist.svg',
  'assets/icons/units/dome_breaker.svg',
  'assets/icons/units/scout.svg',
];

Future<void> precacheSvgAssets() async {
  final futures = _svgAssets.map((path) {
    final loader = SvgAssetLoader(path);
    return svg.cache.putIfAbsent(
      loader.cacheKey(null),
      () => loader.loadBytes(null),
    );
  });
  await Future.wait(futures);
}
