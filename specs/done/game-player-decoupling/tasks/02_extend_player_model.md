# Task 02 — Extend `Player` model with per-player state

## Summary

Transform `Player` from a name-only struct into the owner of **all** per-player state: identity (`id`, `name`), base coordinates, resources, buildings, technologies, units, pending explorations, recruited-unit tracking, and revealed cells. When constructed with a base position, the `Player` computes its own initial `revealedCells` using the existing `RevealAreaCalculator`.

`Game`'s current default-state factories (`defaultResources`, `defaultBuildings`, `defaultTechBranches`, `defaultUnits`) move with this state onto `Player`.

## Implementation Steps

1. **Edit `lib/domain/game/player.dart`**
   - Add imports: `uuid` package, `building`, `resource`, `tech`, `unit`, `map/exploration_order`, `map/grid_position`, `map/reveal_area_calculator`.
   - Add fields (all `@HiveField`, keep `name` at index 0 — renumber others):
     - `@HiveField(0) final String name;`
     - `@HiveField(1) final String id;`
     - `@HiveField(2) int baseX;`
     - `@HiveField(3) int baseY;`
     - `@HiveField(4) final Map<ResourceType, Resource> resources;`
     - `@HiveField(5) final Map<BuildingType, Building> buildings;`
     - `@HiveField(6) final Map<TechBranch, TechBranchState> techBranches;`
     - `@HiveField(7) final Map<UnitType, Unit> units;`
     - `@HiveField(8) final List<UnitType> recruitedUnitTypes;`
     - `@HiveField(9) final List<ExplorationOrder> pendingExplorations;`
     - `@HiveField(10) final Set<GridPosition> revealedCells;`
   - Default constructor:
     ```dart
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
       Set<GridPosition>? revealedCells,
     }) : id = id ?? const Uuid().v4(),
          resources = resources ?? _defaultResources(),
          buildings = buildings ?? _defaultBuildings(),
          techBranches = techBranches ?? _defaultTechBranches(),
          units = units ?? _defaultUnits(),
          recruitedUnitTypes = recruitedUnitTypes ?? [],
          pendingExplorations = pendingExplorations ?? [],
          revealedCells = revealedCells ?? <GridPosition>{};
     ```
   - Named constructor `Player.withBase` that places the player on the map and computes initial reveal:
     ```dart
     Player.withBase({
       required String name,
       required int baseX,
       required int baseY,
       required int mapWidth,
       required int mapHeight,
       String? id,
     }) : this(
            name: name,
            id: id,
            baseX: baseX,
            baseY: baseY,
            revealedCells: _initialRevealedCells(
              baseX: baseX,
              baseY: baseY,
              mapWidth: mapWidth,
              mapHeight: mapHeight,
            ),
          );
     ```
   - Private helpers:
     - `_initialRevealedCells(...)` calls `RevealAreaCalculator.cellsToReveal` with `explorerLevel: 0` and returns a `Set<GridPosition>`.
     - Move `_defaultResources`, `_defaultBuildings`, `_defaultTechBranches`, `_defaultUnits` here (copy from `Game`). Mark them `static`.
2. **Split the file if it exceeds 150 lines**
   - If needed, move default factories into `lib/domain/game/player_defaults.dart` and import them. Target: `player.dart` stays under 150 lines.
3. **Regenerate Hive adapter**
   - Do NOT run `build_runner` in this task — task 15 handles regeneration once all Hive types are final.

## Dependencies

- Task 01 (needs `uuid` in pubspec).
- Reads from existing `RevealAreaCalculator` (unchanged).

## Test Plan

Tests are added in task 19; this task only introduces the model. Skeleton of test cases to keep in mind:

- Default constructor assigns a unique UUID when `id` is omitted.
- Explicit `id` is preserved.
- `Player.withBase(baseX: 10, baseY: 10, mapWidth: 20, mapHeight: 20)` populates `revealedCells` with the cells returned by `RevealAreaCalculator.cellsToReveal(targetX: 10, targetY: 10, explorerLevel: 0, mapWidth: 20, mapHeight: 20)`.
- Two players built independently have distinct `resources` / `buildings` / etc. (no shared references).

## Notes

- `Set<GridPosition>` needs Hive support. `GridPositionAdapter` already exists. Hive's generated code will serialize `Set` as an iterable — confirmed by the `hive_generator` docs. If codegen rejects `Set`, fall back to storing `List<GridPosition>` on the HiveField and exposing a `Set` via a getter/setter pair — but try `Set` first.
- `uuid` import: `import 'package:uuid/uuid.dart';`.
- The file-length rule (<150 lines) is explicit in `CLAUDE.md`. Extracting defaults into `player_defaults.dart` is the recommended escape hatch.
