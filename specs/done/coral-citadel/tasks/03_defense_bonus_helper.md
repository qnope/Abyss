# Task 03 — `CoralCitadelDefenseBonus` helper

## Summary

Create a small pure-Dart helper that maps a Coral Citadel level to its defensive multiplier. This helper is the single source of truth for the bonus values, reused by the UI (tasks 07 & 08) and — eventually — by the future base-defense combat system.

## Implementation steps

1. **Create** `lib/domain/building/coral_citadel_defense_bonus.dart`:
   ```dart
   import 'building.dart';
   import 'building_type.dart';

   /// Defensive multiplier applied to player unit DEF when defending the base.
   ///
   /// Level 0 (not built) → 1.0 (neutral, no effect).
   /// Levels 1–5           → 1.2, 1.4, 1.6, 1.8, 2.0.
   abstract final class CoralCitadelDefenseBonus {
     static double multiplierForLevel(int level) => switch (level) {
       <= 0 => 1.0,
       1 => 1.2,
       2 => 1.4,
       3 => 1.6,
       4 => 1.8,
       >= 5 => 2.0,
     };

     /// Convenience: reads the Citadel level from a buildings map and returns
     /// the matching multiplier. Returns 1.0 when the building is absent.
     static double multiplierFromBuildings(
       Map<BuildingType, Building> buildings,
     ) {
       final level = buildings[BuildingType.coralCitadel]?.level ?? 0;
       return multiplierForLevel(level);
     }

     /// Human-readable bonus string, e.g. "+60%". Returns "aucun" for level 0.
     static String bonusLabel(int level) {
       if (level <= 0) return 'aucun';
       final percent = ((multiplierForLevel(level) - 1) * 100).round();
       return '+$percent%';
     }
   }
   ```

2. Keep the file strictly under 150 lines (it will be ~35 lines).

3. Do **not** plug this helper into the combat engine — the feature SPEC explicitly states the bonus is dormant until the base-attack system is introduced. That integration is out-of-scope.

## Files touched

- `lib/domain/building/coral_citadel_defense_bonus.dart` (new)

## Dependencies

- **Internal**: task 01 (enum case must exist for `multiplierFromBuildings` to type-check against `BuildingType.coralCitadel`).
- **External**: none.

## Test plan

Create `test/domain/building/coral_citadel_defense_bonus_test.dart`:

1. **`multiplierForLevel`**
   - `level 0` → `1.0`
   - `level 1` → `1.2`
   - `level 2` → `1.4`
   - `level 3` → `1.6`
   - `level 4` → `1.8`
   - `level 5` → `2.0`
   - Negative level (e.g. `-3`) → `1.0` (defensive guard).
   - Above max (e.g. `7`) → `2.0` (clamps to max bonus).

2. **`multiplierFromBuildings`**
   - Empty buildings map → `1.0`.
   - Map with `coralCitadel` at level 0 → `1.0`.
   - Map with `coralCitadel` at level 3 → `1.6`.

3. **`bonusLabel`**
   - `level 0` → `'aucun'`
   - `level 1` → `'+20%'`
   - `level 5` → `'+100%'`
   - Make sure rounding is exact (avoid floating-point surprises like `59.999`).

Run `flutter test test/domain/building/coral_citadel_defense_bonus_test.dart`.

## Notes

- Use `abstract final class` with static methods (no instantiation, no state) — matches the style of `BuildingDeactivator` and `PlayerDefaults`.
- The pattern-matched `switch` on an `int` guard (`<= 0`, `>= 5`) is valid Dart 3 syntax and avoids fragile `default` catches.
- Floating-point values are fine here because the downstream consumer will multiply the integer unit DEF and round; no equality traps.
