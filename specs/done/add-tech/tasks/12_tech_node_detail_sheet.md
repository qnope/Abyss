# Task 12 — TechNodeDetailSheet

## Summary

Create a bottom sheet that shows research node details: branch icon + level, bonus description, cost, prerequisites, and a research button.

## Implementation Steps

### 1. Create `lib/presentation/widgets/tech_node_detail_sheet.dart`

**Top-level function:**
```dart
void showTechNodeDetailSheet(
  BuildContext context, {
  required TechBranch branch,
  required int level,
  required TechBranchState state,
  required Map<ResourceType, Resource> resources,
  required Map<BuildingType, Building> buildings,
  required VoidCallback onResearch,
})
```

**Private widget `_TechNodeDetailSheet`:**

Layout:
```
  [Branch SVG Icon — 64px]
  "Militaire — Niveau 3" (colored)
  "Bonus: +60% attaque et défense"
  ──────────────────────────
  IF already researched (level <= state.researchLevel):
    "Recherche complétée ✓" in success color
  ELSE IF level == state.researchLevel + 1 (next node):
    Cost rows (resource icon + available/required)
    Prereq: "Laboratoire Niv. {level}" with lock icon
    [Rechercher] button — disabled if can't afford or lab too low
  ELSE (future node):
    "Recherchez d'abord le niveau {level - 1}"
    Disabled button
```

**Bonus text per branch:**
- Military: `+{level * 20}% attaque et défense`
- Resources: `+{level * 20}% production de ressources`
- Explorer: `+{level * 20}% portée d'exploration`

- Use `TechCostCalculator.researchCost(branch, level)` for costs.
- Use `TechCostCalculator.checkResearch(...)` to determine button state.
- Cost display: red if insufficient (same pattern as `UpgradeSection._costRow`).

**Keep under 130 lines.**

## Files

| Action | Path |
|--------|------|
| Create | `lib/presentation/widgets/tech_node_detail_sheet.dart` |

## Dependencies

- Task 04 (`TechCostCalculator`).
- Task 08 (`TechBranch` extensions).

## Design Notes

- The `level` parameter is the node being viewed (1–5), not necessarily the next researchable one.
- User can tap any node to see its info, even locked ones — just can't research out of order.
- The `onResearch` callback is only wired when the node is the next researchable one.

## Test Plan

- **File:** `test/presentation/widgets/tech_node_detail_sheet_test.dart`
- Test: next researchable node, resources sufficient → button enabled, costs shown.
- Test: already researched node → shows "complétée" message.
- Test: future node (not yet reachable) → shows "recherchez d'abord" message.
- Test: lab level too low → button disabled.
- Covered in task 15.
