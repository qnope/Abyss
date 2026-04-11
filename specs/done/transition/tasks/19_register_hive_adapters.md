# Task 19: Register All New Hive Adapters

## Summary
Register all new Hive type adapters in `GameRepository.initialize()` and regenerate generated code.

## Implementation Steps

1. **Run build_runner** to generate adapters:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **Register adapters** in `lib/data/game_repository.dart`:
   Add after existing registrations:
   ```dart
   // Transition feature
   Hive.registerAdapter(TransitionBaseTypeAdapter());  // typeId 31
   Hive.registerAdapter(TransitionBaseAdapter());       // typeId 32
   Hive.registerAdapter(ReinforcementOrderAdapter());   // typeId 33
   Hive.registerAdapter(CaptureEntryAdapter());         // typeId 34
   Hive.registerAdapter(DescentEntryAdapter());         // typeId 35
   Hive.registerAdapter(ReinforcementEntryAdapter());   // typeId 36
   ```

3. **Add imports** for all new types at the top of the file

4. **Verify registration order**: Leaf types (enums) before composites (TransitionBase uses TransitionBaseType)

## Dependencies
- **Internal**: Task 07 (TransitionBase), Task 10 (ReinforcementOrder), Task 18 (history entries)
- **External**: None

## Test Plan
- Run `flutter test` — verify no Hive registration errors
- Run `flutter analyze`
- Verify game can be saved and loaded (no adapter missing errors)

## Notes
- TypeId assignments: 31-36 are all new, no conflicts with existing 0-30.
- The existing try/catch around `Hive.openBox<Game>` handles migration by deleting the old box if deserialization fails.
