import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../building/building.dart';
import '../building/building_type.dart';
import '../history/history_constants.dart';
import '../history/history_entry.dart';
import '../map/exploration_order.dart';
import '../map/grid_position.dart';
import '../map/reinforcement_order.dart';
import '../map/reveal_area_calculator.dart';
import '../resource/resource.dart';
import '../resource/resource_type.dart';
import '../tech/tech_branch.dart';
import '../tech/tech_branch_state.dart';
import '../unit/unit.dart';
import '../unit/unit_type.dart';
import 'player_defaults.dart';

part 'player.g.dart';

@HiveType(typeId: 0)
class Player extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String id;

  @HiveField(2)
  int baseX;

  @HiveField(3)
  int baseY;

  @HiveField(4)
  final Map<ResourceType, Resource> resources;

  @HiveField(5)
  final Map<BuildingType, Building> buildings;

  @HiveField(6)
  final Map<TechBranch, TechBranchState> techBranches;

  @HiveField(7)
  final Map<int, Map<UnitType, Unit>> unitsPerLevel;

  @HiveField(8)
  final List<UnitType> recruitedUnitTypes;

  @HiveField(9)
  final List<ExplorationOrder> pendingExplorations;

  @HiveField(10)
  final Map<int, List<GridPosition>> revealedCellsPerLevel;

  @HiveField(11)
  final List<HistoryEntry> historyEntries;

  @HiveField(13)
  final List<ReinforcementOrder> pendingReinforcements;

  Player({
    required this.name,
    String? id,
    this.baseX = 0,
    this.baseY = 0,
    Map<ResourceType, Resource>? resources,
    Map<BuildingType, Building>? buildings,
    Map<TechBranch, TechBranchState>? techBranches,
    Map<int, Map<UnitType, Unit>>? unitsPerLevel,
    List<UnitType>? recruitedUnitTypes,
    List<ExplorationOrder>? pendingExplorations,
    Map<int, List<GridPosition>>? revealedCellsPerLevel,
    List<HistoryEntry>? historyEntries,
    List<ReinforcementOrder>? pendingReinforcements,
  })  : id = id ?? const Uuid().v4(),
        resources = resources ?? PlayerDefaults.resources(),
        buildings = buildings ?? PlayerDefaults.buildings(),
        techBranches = techBranches ?? PlayerDefaults.techBranches(),
        unitsPerLevel = unitsPerLevel ?? PlayerDefaults.unitsPerLevel(),
        recruitedUnitTypes = recruitedUnitTypes ?? [],
        pendingExplorations = pendingExplorations ?? [],
        revealedCellsPerLevel = revealedCellsPerLevel ?? {},
        historyEntries = historyEntries ?? <HistoryEntry>[],
        pendingReinforcements = pendingReinforcements ?? [];

  Player.withBase({
    required String name,
    required int baseX,
    required int baseY,
    required int mapWidth,
    required int mapHeight,
    String? id,
    List<HistoryEntry>? historyEntries,
  }) : this(
          name: name,
          id: id,
          baseX: baseX,
          baseY: baseY,
          revealedCellsPerLevel: {
            1: _initialRevealedCells(
              baseX: baseX,
              baseY: baseY,
              mapWidth: mapWidth,
              mapHeight: mapHeight,
            ),
          },
          historyEntries: historyEntries,
        );

  Map<UnitType, Unit> unitsOnLevel(int level) => unitsPerLevel[level] ?? {};

  List<GridPosition> revealedCellsOnLevel(int level) =>
      revealedCellsPerLevel[level] ?? [];

  Set<GridPosition> revealedCellsSetOnLevel(int level) =>
      revealedCellsOnLevel(level).toSet();

  Set<GridPosition> get revealedCells => revealedCellsSetOnLevel(1);

  void addHistoryEntry(HistoryEntry entry) {
    historyEntries.add(entry);
    while (historyEntries.length > kHistoryMaxEntries) {
      historyEntries.removeAt(0);
    }
  }

  bool addRevealedCell(int level, GridPosition pos) {
    final cells = revealedCellsPerLevel.putIfAbsent(level, () => []);
    if (cells.contains(pos)) return false;
    cells.add(pos);
    return true;
  }

  static List<GridPosition> _initialRevealedCells({
    required int baseX,
    required int baseY,
    required int mapWidth,
    required int mapHeight,
  }) {
    return RevealAreaCalculator.cellsToReveal(
      targetX: baseX,
      targetY: baseY,
      explorerLevel: 2,
      mapWidth: mapWidth,
      mapHeight: mapHeight,
    );
  }
}
