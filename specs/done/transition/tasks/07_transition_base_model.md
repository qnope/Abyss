# Task 07: Add TransitionBase Domain Model

## Summary
Create the `TransitionBase` model with type (faille/cheminee), difficulty, guardian data, and capture state. Add `CellContentType.transitionBase` and a `transitionBase` field to `MapCell`.

## Implementation Steps

1. **Create TransitionBaseType enum** in `lib/domain/map/transition_base_type.dart`:
   ```dart
   @HiveType(typeId: 31)
   enum TransitionBaseType {
     @HiveField(0) faille,       // Level 1 → Level 2
     @HiveField(1) cheminee,     // Level 2 → Level 3
   }
   ```

2. **Create TransitionBase class** in `lib/domain/map/transition_base.dart`:
   ```dart
   @HiveType(typeId: 32)
   class TransitionBase {
     @HiveField(0) final TransitionBaseType type;
     @HiveField(1) final String name;          // Generated name
     @HiveField(2) String? capturedBy;         // Player id or null
   }
   ```
   - Add `bool get isCaptured => capturedBy != null`
   - Add `int get difficulty => type == faille ? 4 : 5` (out of 5)
   - Add `int get targetLevel => type == faille ? 2 : 3`

3. **Add to CellContentType** in `lib/domain/map/cell_content_type.dart`:
   - `@HiveField(4) transitionBase`

4. **Add field to MapCell** in `lib/domain/map/map_cell.dart`:
   - `@HiveField(4) final TransitionBase? transitionBase`
   - Update `copyWith` to include `transitionBase` parameter

5. **Update cell_content_type_extensions** in `lib/presentation/extensions/cell_content_type_extensions.dart`:
   - Add `transitionBase` case with display name "Faille Abyssale"

6. **Regenerate Hive adapters**

## Dependencies
- **Internal**: Task 06 (Game model updated)
- **External**: None

## Test Plan
- **File**: `test/domain/map/transition_base_test.dart`
  - Verify `TransitionBase` construction and getters
  - Verify `isCaptured` returns false when `capturedBy` is null
  - Verify `difficulty` returns 4 for faille, 5 for cheminee
  - Verify `targetLevel` returns 2 for faille, 3 for cheminee
- Run `flutter analyze`

## Notes
- Hive typeIds: TransitionBaseType = 31, TransitionBase = 32
- The `name` field will be populated by a name generator during map placement (Task 12).
