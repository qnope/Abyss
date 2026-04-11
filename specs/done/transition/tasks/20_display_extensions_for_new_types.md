# Task 20: Add Display Extensions for New Types

## Summary
Add presentation extensions for all new domain types introduced by the transition feature: TransitionBaseType, new BuildingTypes, new ActionTypes, new HistoryEntryCategories.

## Implementation Steps

1. **Create transition_base_type_extensions.dart** in `lib/presentation/extensions/`:
   ```dart
   extension TransitionBaseTypeExtensions on TransitionBaseType {
     String get displayName => switch (this) {
       TransitionBaseType.faille => 'Faille Abyssale',
       TransitionBaseType.cheminee => 'Cheminee du Noyau',
     };
     String get description => switch (this) {
       TransitionBaseType.faille => 'Passage vers les profondeurs',
       TransitionBaseType.cheminee => 'Passage vers le noyau',
     };
     Color get glowColor => switch (this) {
       TransitionBaseType.faille => AbyssColors.biolumCyan,
       TransitionBaseType.cheminee => AbyssColors.biolumOrange,
     };
   }
   ```

2. **Update building_type_extensions.dart** in `lib/presentation/extensions/`:
   - Add `descentModule` case: name "Module de Descente", description, icon, color
   - Add `pressureCapsule` case: name "Capsule Pressurisee", description, icon, color

3. **Update history_entry_category_extensions.dart** in `lib/presentation/extensions/`:
   - Add `capture`: icon (flag), bg color, label "Capture"
   - Add `descent`: icon (arrow down), bg color, label "Descente"
   - Add `reinforcement`: icon (people), bg color, label "Renforts"

4. **Update history_entry_extensions.dart**:
   - Add accent color for `CaptureEntry`, `DescentEntry`, `ReinforcementEntry`
   - `CaptureEntry.isTappable` → true (opens fight summary)

5. **Ensure all switch statements are exhaustive** after adding new enum values

## Dependencies
- **Internal**: Task 07, 09, 16, 18 (new types exist)
- **External**: None

## Test Plan
- Run `flutter analyze` — all switches exhaustive, zero warnings
- Verify display names render correctly in widget tests

## Notes
- Follow existing extension patterns (pure mapping, no logic).
- Use existing `AbyssColors` palette values.
