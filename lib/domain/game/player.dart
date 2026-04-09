import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../building/building.dart';
import '../building/building_type.dart';
import '../history/history_constants.dart';
import '../history/history_entry.dart';
import '../map/exploration_order.dart';
import '../map/grid_position.dart';
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
  final Map<UnitType, Unit> units;

  @HiveField(8)
  final List<UnitType> recruitedUnitTypes;

  @HiveField(9)
  final List<ExplorationOrder> pendingExplorations;

  @HiveField(10)
  final List<GridPosition> revealedCellsList;

  @HiveField(11)
  final List<HistoryEntry> historyEntries;

  Player({
    required this.name,
    String? id,
    this.baseX = 0,
    this.baseY = 0,
    Map<ResourceType, Resource>? resources,
    Map<BuildingType, Building>? buildings,
    Map<TechBranch, TechBranchState>? techBranches,
    Map<UnitType, Unit>? units,
    List<UnitType>? recruitedUnitTypes,
    List<ExplorationOrder>? pendingExplorations,
    List<GridPosition>? revealedCellsList,
    List<HistoryEntry>? historyEntries,
  })  : id = id ?? const Uuid().v4(),
        resources = resources ?? PlayerDefaults.resources(),
        buildings = buildings ?? PlayerDefaults.buildings(),
        techBranches = techBranches ?? PlayerDefaults.techBranches(),
        units = units ?? PlayerDefaults.units(),
        recruitedUnitTypes = recruitedUnitTypes ?? [],
        pendingExplorations = pendingExplorations ?? [],
        revealedCellsList = revealedCellsList ?? <GridPosition>[],
        historyEntries = historyEntries ?? <HistoryEntry>[];

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
          revealedCellsList: _initialRevealedCells(
            baseX: baseX,
            baseY: baseY,
            mapWidth: mapWidth,
            mapHeight: mapHeight,
          ),
          historyEntries: historyEntries,
        );

  void addHistoryEntry(HistoryEntry entry) {
    historyEntries.add(entry);
    while (historyEntries.length > kHistoryMaxEntries) {
      historyEntries.removeAt(0);
    }
  }

  Set<GridPosition> get revealedCells => revealedCellsList.toSet();

  bool addRevealedCell(GridPosition pos) {
    if (revealedCellsList.contains(pos)) return false;
    revealedCellsList.add(pos);
    return true;
  }

  static List<GridPosition> _initialRevealedCells({
    required int baseX,
    required int baseY,
    required int mapWidth,
    required int mapHeight,
  }) {
    // Level 2 yields a 5x5 square centered on the base for the initial vision.
    return RevealAreaCalculator.cellsToReveal(
      targetX: baseX,
      targetY: baseY,
      explorerLevel: 2,
      mapWidth: mapWidth,
      mapHeight: mapHeight,
    );
  }
}
