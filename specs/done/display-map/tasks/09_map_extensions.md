# Task 9: Map Presentation Extensions

## Summary

Create Flutter presentation extensions for `TerrainType`, `CellContentType`, and `MonsterDifficulty` to provide display names, colors, and SVG asset paths.

## Implementation Steps

1. Create `lib/presentation/extensions/terrain_type_extensions.dart`:
   - Extension `TerrainTypeExtensions` on `TerrainType`:
     - `String get label` → 'Récif', 'Plaine', 'Roche', 'Faille'
     - `String get svgPath` → `'assets/icons/terrain/reef.svg'`, etc.
     - `Color get color` → `AbyssColors.reefPink`, `plainBlue`, `rockGray`, `faultBlack`
     - `bool get isOpaque` → true for rock and fault, false for reef and plain

2. Create `lib/presentation/extensions/cell_content_type_extensions.dart`:
   - Extension `CellContentTypeExtensions` on `CellContentType`:
     - `String get label` → 'Vide', 'Ressources', 'Ruines', 'Repaire'
     - `String? get svgPath` → null for empty, paths for others (`resource_bonus.svg`, `ruins.svg`). For monsterLair, return null (difficulty-specific SVG resolved separately).

   - Extension `MonsterDifficultyExtensions` on `MonsterDifficulty`:
     - `String get label` → 'Facile', 'Moyen', 'Difficile'
     - `String get svgPath` → `'assets/icons/map_content/monster_easy.svg'`, etc.

## Dependencies

- Task 1 (enums)
- Existing `AbyssColors` (reefPink, plainBlue, rockGray, faultBlack already defined)

## Test Plan

- File: `test/presentation/terrain_type_extensions_test.dart`
  - Each TerrainType has a non-empty label
  - Each TerrainType has a valid svgPath string
  - reef/plain are not opaque, rock/fault are opaque

- File: `test/presentation/cell_content_type_extensions_test.dart`
  - empty has null svgPath
  - resourceBonus, ruins have non-null svgPath
  - Each MonsterDifficulty has a valid svgPath

## Notes

- Follow the pattern of existing `resource_type_extensions.dart`.
- Colors are already defined in `AbyssColors` (reefPink, plainBlue, rockGray, faultBlack).
