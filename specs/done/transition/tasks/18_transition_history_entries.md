# Task 18: Add Transition History Entries

## Summary
Add new `HistoryEntry` subclasses for transition events: `CaptureEntry`, `DescentEntry`, and `ReinforcementEntry`.

## Implementation Steps

1. **Create CaptureEntry** in `lib/domain/history/entries/capture_entry.dart`:
   ```dart
   @HiveType(typeId: 34)
   class CaptureEntry extends HistoryEntry {
     @HiveField(0) final int turn;
     @HiveField(1) final String transitionBaseName;
     @HiveField(2) final FightResult fightResult;

     HistoryEntryCategory get category => HistoryEntryCategory.capture;
     String get title => 'Capture: $transitionBaseName';
     String? get subtitle => 'Victoire en ${fightResult.turnCount} tours';
   }
   ```

2. **Create DescentEntry** in `lib/domain/history/entries/descent_entry.dart`:
   ```dart
   @HiveType(typeId: 35)
   class DescentEntry extends HistoryEntry {
     @HiveField(0) final int turn;
     @HiveField(1) final int targetLevel;
     @HiveField(2) final int unitCount;

     HistoryEntryCategory get category => HistoryEntryCategory.descent;
     String get title => 'Descente au Niveau $targetLevel';
     String? get subtitle => '$unitCount unites envoyees';
   }
   ```

3. **Create ReinforcementEntry** in `lib/domain/history/entries/reinforcement_entry.dart`:
   ```dart
   @HiveType(typeId: 36)
   class ReinforcementEntry extends HistoryEntry {
     @HiveField(0) final int turn;
     @HiveField(1) final int targetLevel;
     @HiveField(2) final int unitCount;

     HistoryEntryCategory get category => HistoryEntryCategory.reinforcement;
     String get title => 'Renforts vers Niveau $targetLevel';
     String? get subtitle => '$unitCount unites en transit';
   }
   ```

4. **Add parts** to `lib/domain/history/history_entry.dart`:
   - `part 'entries/capture_entry.dart';`
   - `part 'entries/descent_entry.dart';`
   - `part 'entries/reinforcement_entry.dart';`

5. **Wire into actions** (makeHistoryEntry):
   - `AttackTransitionBaseAction.makeHistoryEntry` → `CaptureEntry` (on successful capture only)
   - `DescendAction.makeHistoryEntry` → `DescentEntry`
   - `SendReinforcementsAction.makeHistoryEntry` → `ReinforcementEntry`

6. **Update history_entry_extensions** in `lib/presentation/extensions/history_entry_extensions.dart`:
   - Add accent color and tappability for new entry types
   - `CaptureEntry` should be tappable (opens fight summary)

## Dependencies
- **Internal**: Task 16 (HistoryEntryCategory updated), Tasks 13-15 (actions exist)
- **External**: None

## Test Plan
- **File**: `test/domain/history/capture_entry_test.dart`
  - Verify title and subtitle generation
- Run `flutter analyze`

## Notes
- Hive typeIds: CaptureEntry = 34, DescentEntry = 35, ReinforcementEntry = 36
- CaptureEntry embeds `FightResult` for tap-to-view fight summary (same pattern as CombatEntry).
