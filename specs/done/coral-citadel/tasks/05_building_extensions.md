# Task 05 — Presentation extensions for Coral Citadel

## Summary

Wire the new building type into the three presentation extensions that the UI uses to render buildings: color, display name, description, and SVG icon path. Without this task, any list that renders `BuildingType.coralCitadel` throws a "missing case" exception.

## Implementation steps

1. **Edit** `lib/presentation/extensions/building_type_extensions.dart`:

   a. **`color`** extension — use `AbyssColors.coralPink` (fits the brief: corail rose). Place the branch near `coralMine` for readability.
      ```dart
      BuildingType.coralCitadel => AbyssColors.coralPink,
      ```
      > If a distinct accent is desired, also acceptable: `AbyssColors.biolumPink`. The SPEC pins the SVG palette, not the tint used for the building card header.

   b. **`displayName`**:
      ```dart
      BuildingType.coralCitadel => 'Citadelle corallienne',
      ```

   c. **`description`** — short text used inside `BuildingDetailSheet`. Keep it ≤ 2 sentences so the sheet stays compact. Important: hint at the dormant state so the player is not confused.
      ```dart
      BuildingType.coralCitadel =>
        'Forteresse corallienne massive qui renforce la défense des unités '
        'stationnées dans votre base. Son bouclier s\'activera avec l\'arrivée '
        'des menaces abyssales.',
      ```

   d. **`iconPath`**:
      ```dart
      BuildingType.coralCitadel => 'assets/icons/buildings/coral_citadel.svg',
      ```

2. **Verify file length** — the extensions file is 56 lines currently; after this change it should stay under 80. No refactor needed.

3. **Sanity run** — `flutter analyze` must now report zero missing-case warnings for building switches in `lib/presentation/` (combined with tasks 02 and 04 for domain switches). The SVG path referenced here is produced by task 06.

## Files touched

- `lib/presentation/extensions/building_type_extensions.dart`

## Dependencies

- **Internal**: task 01 (enum case).
- **Soft link**: task 06 creates the SVG file. Until task 06 lands, a debug build will still boot but rendering the Citadel card will throw an asset-not-found exception at runtime. Task 06 is independent, so land either order — but prefer doing 05 and 06 back-to-back.
- **External**: none.

## Test plan

1. **Unit test** `test/presentation/extensions/building_type_extensions_test.dart` (create if missing, or extend the existing file):
   - `BuildingType.coralCitadel.displayName == 'Citadelle corallienne'`
   - `BuildingType.coralCitadel.iconPath == 'assets/icons/buildings/coral_citadel.svg'`
   - `BuildingType.coralCitadel.description` is non-empty and contains the word `'défense'` (regression guard against accidentally dropping the player hint).
   - `BuildingType.coralCitadel.color == AbyssColors.coralPink`.

2. **Smoke check** — run `flutter test test/presentation/` after task 06 lands (SVG must exist for widget tests to render). If task 05 lands first, skip the rendering smoke until 06 is done.

## Notes

- Keep all four extension cases together, in the same relative order in each `switch`, so future readers can eyeball the symmetry.
- Do **not** introduce a new `AbyssColors.citadelPink` constant; re-use existing `coralPink`. Adding a new color is out of scope and would need theme review.
- The description intentionally teases the dormant state without saying "dormant" — the dedicated label in task 07 will carry that UX weight.
