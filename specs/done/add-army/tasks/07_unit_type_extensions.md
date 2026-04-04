# Task 07: Create UnitType Extensions

## Summary

Create presentation extensions on `UnitType` for display name, color, icon path, and role description. Follows the `BuildingTypeExtensions` pattern.

## Implementation Steps

### 1. Create `lib/presentation/extensions/unit_type_extensions.dart`

Extension `UnitTypeExtensions on UnitType`:

#### `String get displayName`

| UnitType    | Display Name  |
|-------------|---------------|
| scout       | Eclaireur     |
| harpoonist  | Harponneur    |
| guardian     | Gardien       |
| domeBreaker | Briseur       |
| siphoner    | Siphonneur    |
| saboteur    | Saboteur      |

#### `Color get color`

Use colors from `unit_icons.md` architecture:
| UnitType    | Color (from gradient start) |
|-------------|----------------------------|
| scout       | `Color(0xFF0D47A1)`        |
| harpoonist  | `Color(0xFFBF360C)`        |
| guardian     | `Color(0xFF607D8B)`        |
| domeBreaker | `Color(0xFFE65100)`        |
| siphoner    | `Color(0xFF4A148C)`        |
| saboteur    | `Color(0xFF1B5E20)`        |

#### `String get iconPath`

Pattern: `'assets/icons/units/${name_with_underscore}.svg'`
- scout → `assets/icons/units/scout.svg`
- domeBreaker → `assets/icons/units/dome_breaker.svg`

Use a switch expression for the camelCase → snake_case mapping.

#### `String get role`

| UnitType    | Role         |
|-------------|--------------|
| scout       | Eclaireur    |
| harpoonist  | DPS          |
| guardian     | Tank         |
| domeBreaker | Siege        |
| siphoner    | Voleur       |
| saboteur    | Verre-canon  |

## Dependencies

- Task 01 (UnitType enum)

## Test Plan

- **File**: `test/presentation/extensions/unit_type_extensions_test.dart`
  - All 6 unit types have a non-empty displayName
  - All 6 unit types have an iconPath matching `assets/icons/units/*.svg`
  - `UnitType.domeBreaker.iconPath` is `assets/icons/units/dome_breaker.svg`
  - All 6 unit types have a color

## Notes

- All strings are in French (no i18n for now).
- Icon SVG files already exist in `assets/icons/units/`.
