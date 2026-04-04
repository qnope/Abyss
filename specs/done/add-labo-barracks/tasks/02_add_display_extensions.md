# Task 02: Add display extensions for laboratory and barracks

## Summary
Add displayName, description, iconPath, and color for the two new building types in `BuildingTypeInfo` and `BuildingTypeColor` extensions.

## Implementation Steps

### 1. Edit `lib/presentation/extensions/building_type_extensions.dart`

#### BuildingTypeColor extension — add to the `color` switch:
- `BuildingType.laboratory => AbyssColors.biolumPurple` (or another fitting color from AbyssColors — check available colors)
- `BuildingType.barracks => AbyssColors.coralPink` (or another fitting color)

#### BuildingTypeInfo extension — add to each switch:

**displayName:**
- `BuildingType.laboratory => 'Laboratoire'`
- `BuildingType.barracks => 'Caserne'`

**description:**
- `BuildingType.laboratory => 'Centre de recherche sous-marin pour développer de nouvelles technologies.'`
- `BuildingType.barracks => 'Forme et entraîne vos unités militaires sous-marines.'`

**iconPath:**
- `BuildingType.laboratory => 'assets/icons/buildings/laboratory.svg'`
- `BuildingType.barracks => 'assets/icons/buildings/barracks.svg'`

## Dependencies
- Task 01 (enum values must exist)

## Test Plan
- **File:** `test/presentation/extensions/building_type_extensions_test.dart` (create if not exists, or add to existing test)
- Test that `BuildingType.laboratory.displayName` == `'Laboratoire'`
- Test that `BuildingType.barracks.displayName` == `'Caserne'`
- Test that `BuildingType.laboratory.iconPath` == `'assets/icons/buildings/laboratory.svg'`
- Test that `BuildingType.barracks.iconPath` == `'assets/icons/buildings/barracks.svg'`
