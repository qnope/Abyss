# Extensions

`lib/presentation/extensions/` — Bridge between domain enums and UI display values.

## Overview

Each extension file adds `displayName`, `description`, `iconPath`, and `color` getters to a domain enum using Dart `extension` types. This keeps domain models free of Flutter imports while providing consistent UI representations.

## Files

| File | Extends | Provides |
|------|---------|----------|
| `building_type_extensions.dart` | `BuildingType` | `displayName`, `description`, `iconPath`, `color` |
| `resource_type_extensions.dart` | `ResourceType` | `displayName`, `iconPath`, `color` |
| `unit_type_extensions.dart` | `UnitType` | `displayName`, `description`, `iconPath` |
| `tech_branch_extensions.dart` | `TechBranch` | `displayName` |
| `terrain_type_extensions.dart` | `TerrainType` | Display values for map rendering |
| `cell_content_type_extensions.dart` | `CellContentType` | Display values for map cell contents |
| `history_entry_category_extensions.dart` | `HistoryEntryCategory` | `icon`, `backgroundColor(theme)`, `label` — drives history card tinting and filter chips |
| `history_entry_extensions.dart` | `HistoryEntry` (sealed) | `accentColor(theme)` (combat wins glow success / losses glow error), `isTappable` (combat only) |

## How to Use

Import the relevant extension and call getters directly on enum values:

```dart
import 'extensions/building_type_extensions.dart';

final name = BuildingType.barracks.displayName; // 'Caserne'
final icon = BuildingType.barracks.iconPath;     // 'assets/icons/buildings/barracks.svg'
final color = BuildingType.barracks.color;       // AbyssColors.biolumPink
```

## Pattern

All extensions use `switch` expressions for exhaustive matching — adding a new enum value will produce a compile error until the extension is updated.
