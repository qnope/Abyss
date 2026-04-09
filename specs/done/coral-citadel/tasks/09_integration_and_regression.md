# Task 09 — Integration tests, persistence, legacy save regression, final QA

## Summary

Close the feature with end-to-end coverage: a full build + upgrade flow on a live `Game`, Hive round-trip persistence for an in-progress Citadel, a legacy-save regression test, and the final quality gates (`flutter analyze` / `flutter test`).

## Implementation steps

### 9.1 — Construction + upgrade flow integration test

**Create** `test/integration/coral_citadel_flow_test.dart` (or extend the existing integration test folder — check `test/` layout first):

- Bootstrap a `Game` with a single human player via the existing test helpers (look for `GameFixtures` / `PlayerFixtures` — use them if present, otherwise build manually from `Game`, `Player`, `PlayerDefaults`).
- Grant the player:
  - HQ level 3.
  - Coral / ore / energy / pearls large enough for at least two upgrade cycles.
- Execute `UpgradeBuildingAction(buildingType: BuildingType.coralCitadel).execute(game, player)`.
- Assert:
  - `player.buildings[coralCitadel]!.level == 1`.
  - Coral / ore / energy / pearls decreased by exactly `{120, 120, 60, 5}`.
- Increase HQ to level 5, grant additional resources, execute the action again.
- Assert:
  - Level is now 2.
  - Resources debited by exactly `{240, 240, 120, 10}`.
- Attempt to upgrade past the HQ prerequisite (HQ 5 but trying to reach level 3 which needs HQ 7):
  - `validate` / `execute` returns failure; level stays at 2; resources unchanged.

### 9.2 — Hive persistence round-trip

**Create** `test/data/game_repository_coral_citadel_test.dart` (or extend the existing repository test file):

- Initialize the test-mode Hive (follow the pattern from the existing `game_repository_test.dart` — likely `Hive.init(Directory.systemTemp.createTempSync().path)` + register adapters).
- Save a `Game` with a Citadel at level 3, energy 10 (deducted once), HQ at level 7, pearls 42.
- Close and re-open the box.
- Load the game back.
- Assert:
  - `buildings[coralCitadel]!.level == 3`.
  - All other buildings are intact.
  - Resources are exactly what was saved.

### 9.3 — Legacy save regression

**Create** `test/data/legacy_save_without_citadel_test.dart`:

- Construct a `Game` **without** adding the `coralCitadel` entry to `player.buildings` (simulate a save made before task 01). The simplest way: after calling `PlayerDefaults.buildings()`, `remove(BuildingType.coralCitadel)` before passing the map to the `Player` constructor.
- Save and reload the game via a real `GameRepository` (test mode Hive).
- Assert:
  - The load does **not** throw.
  - `player.buildings[coralCitadel]` is `null` (the legacy save genuinely had no entry).
  - `CoralCitadelDefenseBonus.multiplierFromBuildings(player.buildings) == 1.0`.
- If `PlayerDefaults` is re-applied on load (patching missing buildings), update the assertion to expect `level == 0` instead of `null`. Inspect `GameRepository.load` to confirm which behavior is in effect; pick the assertion that matches the actual contract and document the choice in a comment inside the test.

### 9.4 — Full quality gate run

Run, from the repo root, in order:

1. `flutter analyze` — must report **zero** warnings/errors. Any new lint introduced by this feature must be fixed before landing.
2. `flutter test` — all tests (existing + new) must pass.
3. `flutter test --coverage` (optional but recommended) — spot-check that the new domain code (`coral_citadel_defense_bonus.dart`, Citadel cases in `building_cost_calculator.dart`) are fully covered.
4. **Manual smoke** — `flutter run -d chrome` (or any available device):
   - Start a new game, boost HQ to level 3 via the console or by editing seed values locally, build the Citadel, then upgrade it once.
   - Verify the badge appears in the Army tab and HQ sheet.
   - Verify the Citadel card renders the SVG at the tile size.
   - Verify the dormant mention is visible in the Citadel detail sheet.

### 9.5 — Architecture doc update

**Edit** `specs/architecture/domain/building/README.md`:
- Bump the "7 values" / "8 values" wording and add a bullet for `coralCitadel`.
- Add a short **Defense bonus** subsection describing `CoralCitadelDefenseBonus`.
- Update the deactivation priority list block to include the Citadel at position 1.

Keep the README under ~100 lines.

## Files touched

- `test/integration/coral_citadel_flow_test.dart` (new)
- `test/data/game_repository_coral_citadel_test.dart` (new)
- `test/data/legacy_save_without_citadel_test.dart` (new)
- `specs/architecture/domain/building/README.md` (modified)

## Dependencies

- **Internal**: tasks 01–08 must all be complete. This task is the final seal.
- **External**: Hive test mode (already used in existing tests).

## Test plan

This task **is** the test plan for the whole feature. The success criteria:
- All tests run by tasks 01–08 still pass.
- The three new test files (9.1, 9.2, 9.3) pass.
- `flutter analyze` exit code 0.
- Manual smoke confirms the SVG renders and the badge appears.

## Notes

- Do not mock the Hive layer in 9.2 / 9.3 — integration tests must hit a real Hive box (pattern already in the repo).
- If `legacy_save_without_citadel_test.dart` reveals a crash in `PlayerDefaults.buildings()` merging logic, **that** is the bug to fix (the SPEC explicitly calls out backward compatibility as a requirement) — fix it in `lib/domain/game/player_defaults.dart` or `lib/data/game_repository.dart` and add a note in the task completion comment.
- The `flutter analyze` gate is the acceptance check for the project rule "file ≤ 150 lines" — if analyze surfaces the rule as a lint, treat it as a blocker. If the repo does not lint this rule, manually `wc -l` each touched file before closing the task.
- Remember to update `specs/architecture/domain/building/README.md` — architecture docs are part of the feature, not an afterthought.
