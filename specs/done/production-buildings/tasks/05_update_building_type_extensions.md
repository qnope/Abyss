# Task 05 — Update BuildingTypeExtensions

## Summary
Add display names, descriptions, icon paths, and colors for the 4 production buildings.

## Implementation Steps

### 1. Edit `lib/presentation/extensions/building_type_extensions.dart`

#### `BuildingTypeColor.color`
Map each production building to its corresponding resource color:
```dart
BuildingType.algaeFarm => AbyssColors.algaeGreen,
BuildingType.coralMine => AbyssColors.coralPink,
BuildingType.oreExtractor => AbyssColors.oreBlue,
BuildingType.solarPanel => AbyssColors.energyYellow,
```

#### `BuildingTypeInfo.displayName`
```dart
BuildingType.algaeFarm => 'Ferme d\'algues',
BuildingType.coralMine => 'Mine de corail',
BuildingType.oreExtractor => 'Extracteur de minerai',
BuildingType.solarPanel => 'Panneau solaire',
```

#### `BuildingTypeInfo.description`
```dart
BuildingType.algaeFarm => 'Cultive des algues pour nourrir votre colonie sous-marine.',
BuildingType.coralMine => 'Extrait du corail des récifs pour la construction.',
BuildingType.oreExtractor => 'Fore les profondeurs pour extraire du minerai océanique.',
BuildingType.solarPanel => 'Capte l\'énergie solaire pour alimenter vos installations.',
```

#### `BuildingTypeInfo.iconPath`
```dart
BuildingType.algaeFarm => 'assets/icons/buildings/algae_farm.svg',
BuildingType.coralMine => 'assets/icons/buildings/coral_mine.svg',
BuildingType.oreExtractor => 'assets/icons/buildings/ore_extractor.svg',
BuildingType.solarPanel => 'assets/icons/buildings/solar_panel.svg',
```

## Dependencies
- Task 01 (BuildingType enum values)

## Test Plan
- No dedicated tests needed (switch expressions are exhaustive; compilation validates completeness).
- Widget tests in Task 09 will exercise display names.

## Notes
- SVG assets already exist in `assets/icons/buildings/`.
- Colors match the resource colors from `AbyssColors` since each building produces one resource.
