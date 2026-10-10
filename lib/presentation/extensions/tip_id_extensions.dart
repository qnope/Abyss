import '../../domain/building/building_type.dart';
import '../../domain/event/random_event_type.dart';
import '../../domain/map/cell_content_type.dart';
import '../../domain/map/monster_difficulty.dart';
import '../../domain/map/monster_family.dart';
import '../../domain/objective/tip/tip_id.dart';
import '../../domain/unit/unit_type.dart';
import '../widgets/guide/guide_bubble.dart';
import 'building_type_extensions.dart';
import 'cell_content_type_extensions.dart';
import 'monster_family_extensions.dart';
import 'random_event_type_extensions.dart';
import 'unit_type_extensions.dart';

/// Display primitives for a [TipId].
extension TipIdDisplay on TipId {
  /// Art of the game shown on the card: the building, unit, monster or
  /// event it explains, the guide's portrait when none fits.
  String get illustration => switch (this) {
    TipId.noiseGauge => MonsterDifficulty.easy.svgPath,
    TipId.worksites => BuildingType.headquarters.iconPath,
    TipId.techChoice => BuildingType.laboratory.iconPath,
    TipId.raidAnnounced => MonsterDifficulty.hard.svgPath,
    TipId.raidReport => UnitType.harpoonist.iconPath,
    TipId.lastChance => BuildingType.coralCitadel.iconPath,
    TipId.lair => MonsterDifficulty.medium.svgPath,
    TipId.monsterFamilies =>
      MonsterFamily.armoured.svgPathAt(MonsterDifficulty.medium),
    TipId.volcanoWave => krakenSvgPath,
    TipId.factionAttack => UnitType.guardian.iconPath,
    TipId.chestAndRuins => CellContentType.ruins.svgPath!,
    TipId.transitionBase || TipId.events => GuideBubble.portraitPath,
    TipId.descent => BuildingType.descentModule.iconPath,
    TipId.warmCurrent => RandomEventType.warmCurrent.illustration,
    TipId.wreck => RandomEventType.wreck.illustration,
    TipId.predators => RandomEventType.predators.illustration,
    TipId.storm => RandomEventType.storm.illustration,
    TipId.survivors => RandomEventType.survivors.illustration,
    TipId.caravan => RandomEventType.caravan.illustration,
    TipId.coldCurrent => RandomEventType.coldCurrent.illustration,
  };
}
