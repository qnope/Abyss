# Task 08: Add isBoss to Combatant and Create GuardianFactory

## Summary
Add an `isBoss` flag to `Combatant` for boss combat display and victory conditions. Create `GuardianFactory` that builds the guardian armies for each transition base type.

## Implementation Steps

1. **Add isBoss to Combatant** in `lib/domain/fight/combatant.dart`:
   - `@HiveField(6) final bool isBoss`
   - Default to `false` in constructor
   - No change to existing combatant creation (all default to false)

2. **Create GuardianFactory** in `lib/domain/fight/guardian_factory.dart`:
   ```dart
   class GuardianFactory {
     static List<Combatant> forFaille() => [
       Combatant(side: CombatSide.monster, typeKey: 'leviathan',
         maxHp: 100, atk: 15, def: 10, isBoss: true),
       ...List.generate(5, (_) => Combatant(
         side: CombatSide.monster, typeKey: 'sentinelle',
         maxHp: 30, atk: 8, def: 5)),
     ];

     static List<Combatant> forCheminee() => [
       Combatant(side: CombatSide.monster, typeKey: 'titanVolcanique',
         maxHp: 200, atk: 25, def: 15, isBoss: true),
       ...List.generate(8, (_) => Combatant(
         side: CombatSide.monster, typeKey: 'golemMagma',
         maxHp: 50, atk: 12, def: 8)),
     ];

     static List<Combatant> forType(TransitionBaseType type) =>
       switch (type) {
         TransitionBaseType.faille => forFaille(),
         TransitionBaseType.cheminee => forCheminee(),
       };
   }
   ```

3. **Regenerate Hive adapters** (Combatant has new field)

## Dependencies
- **Internal**: Task 07 (TransitionBaseType enum)
- **External**: None

## Test Plan
- **File**: `test/domain/fight/guardian_factory_test.dart`
  - Verify `forFaille()` returns 6 combatants (1 boss + 5 escorts)
  - Verify boss has `isBoss: true`, escorts have `isBoss: false`
  - Verify stats match spec values
  - Verify `forCheminee()` returns 9 combatants (1 boss + 8 escorts)
- **File**: `test/domain/fight/combatant_test.dart`
  - Verify `isBoss` defaults to false for backward compat
- Run `flutter analyze`

## Notes
- Adding `@HiveField(6)` to Combatant is backward-compatible with Hive (new fields default to null/false for existing data).
- The `isBoss` flag is used in AttackTransitionBaseAction (Task 14) to check if the Abyss Admiral survived and in UI for narrative display.
