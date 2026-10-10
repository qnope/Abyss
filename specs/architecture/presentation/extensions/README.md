# Extensions

`lib/presentation/extensions/` — Bridge between domain enums and UI display values.

## Overview

Each extension file adds display values to a domain enum using Dart `extension` types. This keeps domain models free of Flutter imports while providing consistent UI representations.

Texts are methods taking the translations (`displayName(l10n)`, `label(l10n)`, …) and read their wording from the ARB files (see `../l10n/README.md`). Icons, colors and SVG paths stay plain getters.

## Files

| File | Extends | Provides |
|------|---------|----------|
| `building_type_extensions.dart` | `BuildingType` | `displayName(l10n)`, `description(l10n)`, `iconPath`, `color` |
| `resource_type_extensions.dart` | `ResourceType` | `displayName(l10n)`, `flavorText(l10n)`, `color`; `gainLabel(l10n)` on a gains map |
| `unit_type_extensions.dart` | `UnitType` | `displayName(l10n)`, `role(l10n)`, `roleEffect(l10n)`, `iconPath`, `color` |
| `tech_branch_extensions.dart` | `TechBranch` | `displayName(l10n)`, `description(l10n)`, `iconPath`, `color` |
| `terrain_type_extensions.dart` | `TerrainType` | Display values for map rendering |
| `cell_content_type_extensions.dart` | `CellContentType` | Display values for map cell contents |
| `history_entry_category_extensions.dart` | `HistoryEntryCategory` | `icon`, `backgroundColor(theme)`, `label(l10n)` — drives history card tinting and filter chips |
| `history_entry_extensions.dart` | `HistoryEntry` (sealed) | `accentColor(theme)` (combat wins glow success / losses glow error), `isTappable` (combat only) |

## How to Use

Import the relevant extension and call it on enum values; widgets pass `context.l10n`, code without a `BuildContext` gets the translations from its caller:

```dart
import 'extensions/building_type_extensions.dart';

final name = BuildingType.barracks.displayName(context.l10n); // 'Caserne'
final icon = BuildingType.barracks.iconPath;     // 'assets/icons/buildings/barracks.svg'
final color = BuildingType.barracks.color;       // AbyssColors.biolumPink
```

## Pattern

All extensions use `switch` expressions for exhaustive matching — adding a new enum value will produce a compile error until the extension is updated.
