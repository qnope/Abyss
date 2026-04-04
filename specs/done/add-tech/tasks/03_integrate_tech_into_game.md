# Task 03 — Integrate Tech State into Game + Hive Adapters

## Summary

Add a `techBranches` field to the `Game` model, create a default factory, and register the new Hive adapters in `GameRepository`.

## Implementation Steps

### 1. Update `lib/domain/game.dart`

- Add import for `tech_branch.dart` and `tech_branch_state.dart`.
- Add a new Hive field:
  ```dart
  @HiveField(5)
  final Map<TechBranch, TechBranchState> techBranches;
  ```
- Update constructor to accept optional `techBranches` parameter with default:
  ```dart
  Game({
    ...
    Map<TechBranch, TechBranchState>? techBranches,
  }) : ...
       techBranches = techBranches ?? defaultTechBranches();
  ```
- Add static factory:
  ```dart
  static Map<TechBranch, TechBranchState> defaultTechBranches() {
    return {
      TechBranch.military: TechBranchState(branch: TechBranch.military),
      TechBranch.resources: TechBranchState(branch: TechBranch.resources),
      TechBranch.explorer: TechBranchState(branch: TechBranch.explorer),
    };
  }
  ```

### 2. Regenerate `game.g.dart`

- Run `dart run build_runner build --delete-conflicting-outputs`.

### 3. Update `lib/data/game_repository.dart`

- Add imports for `tech_branch.dart` and `tech_branch_state.dart`.
- Register new adapters **before** `GameAdapter` (order matters):
  ```dart
  Hive.registerAdapter(TechBranchAdapter());
  Hive.registerAdapter(TechBranchStateAdapter());
  ```
  Insert after `ResourceAdapter()` and before `PlayerAdapter()`.

## Files

| Action | Path |
|--------|------|
| Edit | `lib/domain/game.dart` |
| Generated | `lib/domain/game.g.dart` |
| Edit | `lib/data/game_repository.dart` |

## Dependencies

- Task 01 (`TechBranch` enum).
- Task 02 (`TechBranchState` model).

## Design Notes

- Existing save files won't have `techBranches` (HiveField 5 is new). Hive returns `null` for missing fields, so the constructor default `?? defaultTechBranches()` handles migration seamlessly.
- The delete-and-reopen recovery in `GameRepository.initialize()` already protects against corrupt data.

## Test Plan

- **File:** `test/domain/game_test.dart` — add test for `defaultTechBranches()` presence and correctness.
- Verify `Game()` creates 3 default tech branches, all locked, all at level 0.
- Covered in task 14.
