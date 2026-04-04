# Task 13 — Wire Tech Tab in GameScreen

## Summary

Replace the Tech tab placeholder with the `TechTreeView` widget and wire up unlock/research actions.

## Implementation Steps

### 1. Update `lib/presentation/screens/game_screen.dart`

**Add imports:**
```dart
import '../../domain/unlock_branch_action.dart';
import '../../domain/research_tech_action.dart';
import '../widgets/tech_tree_view.dart';
import '../widgets/tech_branch_detail_sheet.dart';
import '../widgets/tech_node_detail_sheet.dart';
```

**Update `_buildTabContent()` — replace case 3:**

```dart
3 => TechTreeView(
  techBranches: widget.game.techBranches,
  buildings: widget.game.buildings,
  resources: widget.game.resources,
  onBranchTap: _showBranchDetail,
  onNodeTap: _showNodeDetail,
),
```

**Add `_showBranchDetail(TechBranch branch)` method:**
```dart
void _showBranchDetail(TechBranch branch) {
  showTechBranchDetailSheet(
    context,
    branch: branch,
    state: widget.game.techBranches[branch]!,
    resources: widget.game.resources,
    buildings: widget.game.buildings,
    onUnlock: () => _unlockBranch(branch),
  );
}
```

**Add `_unlockBranch(TechBranch branch)` method:**
```dart
void _unlockBranch(TechBranch branch) {
  final action = UnlockBranchAction(branch: branch);
  final result = ActionExecutor().execute(action, widget.game);
  if (result.isSuccess) {
    setState(() {});
    Navigator.pop(context);
  }
}
```

**Add `_showNodeDetail(TechBranch branch, int level)` method:**
```dart
void _showNodeDetail(TechBranch branch, int level) {
  showTechNodeDetailSheet(
    context,
    branch: branch,
    level: level,
    state: widget.game.techBranches[branch]!,
    resources: widget.game.resources,
    buildings: widget.game.buildings,
    onResearch: () => _researchTech(branch),
  );
}
```

**Add `_researchTech(TechBranch branch)` method:**
```dart
void _researchTech(TechBranch branch) {
  final action = ResearchTechAction(branch: branch);
  final result = ActionExecutor().execute(action, widget.game);
  if (result.isSuccess) {
    setState(() {});
    Navigator.pop(context);
  }
}
```

**Remove `TabPlaceholder` import** if no longer used (Map and Army still use it — keep it).

### 2. Check file length

After edits, `game_screen.dart` will be around ~170 lines. If it exceeds 150, extract tech-related methods into a mixin or pass them via a helper. Options:
- Extract `_showBranchDetail`, `_showNodeDetail`, `_unlockBranch`, `_researchTech` into a separate file as free functions that take `context`, `game`, and `setState` callback.
- Or keep it at ~160 lines if the overshoot is minor — discuss with reviewer.

## Files

| Action | Path |
|--------|------|
| Edit | `lib/presentation/screens/game_screen.dart` |

## Dependencies

- Task 05 (`UnlockBranchAction`).
- Task 06 (`ResearchTechAction`).
- Task 10 (`TechTreeView`).
- Task 11 (`TechBranchDetailSheet`).
- Task 12 (`TechNodeDetailSheet`).

## Design Notes

- Same pattern as `_showBuildingDetail` / `_upgradeBuilding` — keeps GameScreen as the coordinator.
- `Navigator.pop(context)` closes the bottom sheet after a successful action, just like building upgrades.
- The ResourceBar already shows updated production because `ProductionCalculator` is called in `build()` after `setState`.

## Test Plan

- **File:** `test/presentation/screens/game_screen_test.dart` — add/update tests.
- Test: Tech tab shows TechTreeView (not placeholder).
- Test: tapping a branch opens bottom sheet.
- Covered in task 15.
