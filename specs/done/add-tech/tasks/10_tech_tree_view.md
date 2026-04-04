# Task 10 — TechTreeView

## Summary

Build the main tech tree layout widget that displays the full tree: root lab node, 3 branches, 5 nodes per branch, with connecting lines.

## Implementation Steps

### 1. Create `lib/presentation/widgets/tech_tree_view.dart`

**Props:**
```dart
class TechTreeView extends StatelessWidget {
  final Map<TechBranch, TechBranchState> techBranches;
  final Map<BuildingType, Building> buildings;
  final Map<ResourceType, Resource> resources;
  final void Function(TechBranch branch) onBranchTap;
  final void Function(TechBranch branch, int level) onNodeTap;
}
```

**Layout structure** (vertical scrollable):

```
    [Lab Root Node]           ← BuildingIcon for laboratory
         |
   ------+------
   |     |     |
 [Mil] [Res] [Exp]          ← 3 branch header nodes
   |     |     |
 [1]   [1]   [1]            ← sub-nodes level 1
   |     |     |
 [2]   [2]   [2]
   |     |     |
 [3]   [3]   [3]
   |     |     |
 [4]   [4]   [4]
   |     |     |
 [5]   [5]   [5]
```

**Implementation approach:**

```dart
SingleChildScrollView(
  child: Column(
    children: [
      _buildRootNode(),     // Lab icon, greyed if lab level 0
      _buildConnector(),    // vertical line
      Row(                  // 3 branches side by side
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: TechBranch.values.map(_buildBranch).toList(),
      ),
    ],
  ),
)
```

**`_buildBranch(TechBranch branch)` → Column:**
- Branch header `TechNodeWidget` (state depends on unlocked)
- For levels 1–5: connector + `TechNodeWidget`
- Node state logic:
  - `level <= state.researchLevel` → `researched`
  - `level == state.researchLevel + 1` AND branch unlocked AND lab level >= level → `accessible`
  - Otherwise → `locked`

**Connectors:** Simple `Container(width: 2, height: 16, color: ...)`:
- Researched → branch color
- Otherwise → `AbyssColors.disabled`

**Root node:** Show `BuildingIcon(type: BuildingType.laboratory)`, greyscale if lab level == 0.

### 2. Create helper `_nodeStateFor(TechBranchState state, int level, int labLevel) → TechNodeState`

This helper computes the visual state for each node.

**Target: ~100–130 lines** — split into `_buildRootNode`, `_buildBranch`, `_buildConnector` methods.

## Files

| Action | Path |
|--------|------|
| Create | `lib/presentation/widgets/tech_tree_view.dart` |

## Dependencies

- Task 02 (`TechBranchState`).
- Task 08 (`TechBranch` extensions for colors, icons, names).
- Task 09 (`TechNodeWidget`, `TechNodeState`).

## Design Notes

- The tree uses `Row` + `Column` layout — no CustomPaint needed. Simpler, more testable.
- Connectors are simple colored containers acting as lines.
- Callbacks for taps are passed up — the parent (`GameScreen`) decides what to show.
- If tree exceeds 150 lines, extract the branch column into `_TechBranchColumn` private widget in a separate file `lib/presentation/widgets/tech_branch_column.dart`.

## Test Plan

- **File:** `test/presentation/widgets/tech_tree_view_test.dart`
- Test: lab level 0 → root node greyscale, all branches locked.
- Test: lab level 1, military unlocked → military branch header colored, node 1 accessible.
- Test: military researched level 3 → nodes 1-3 researched, node 4 accessible (if lab level >= 4), node 5 locked.
- Test: tapping a branch header calls `onBranchTap`.
- Covered in task 15.
