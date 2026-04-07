# Task 07 — Create TreasureSheet widget

## Summary

Create a bottom sheet for collectible cells (resourceBonus and ruins) with resource information and a "Collecter le trésor" action button.

## Implementation Steps

1. **Create `lib/presentation/widgets/map/treasure_sheet.dart`**

   - Create `showTreasureSheet(BuildContext, {required int targetX, required int targetY, required CellContentType contentType, ResourceType? bonusResourceType, int? bonusAmount, required VoidCallback onCollect})` top-level function
   - Uses `showModalBottomSheet` like `ExplorationSheet`
   - Internal `_TreasureSheet` stateless widget:
     - Icon: content type SVG (resource_bonus.svg or ruins.svg), 64px, centered
     - Title: `'Trésor ($targetX, $targetY)'` (headlineSmall, biolumCyan)
     - **If resourceBonus:**
       - Info row: `'Type'` → resource type label (from ResourceType extension)
       - Info row: `'Montant'` → bonus amount
     - **If ruins:**
       - Text: `'Ressources aléatoires et perles'` (bodyMedium, onSurfaceDim)
     - Divider
     - FilledButton: `'Collecter le trésor'` → pops sheet, calls `onCollect`

2. **Add `label` getter to ResourceType extension if not already present**
   - Check `lib/presentation/extensions/resource_type_extensions.dart`
   - Add French labels: algae→"Algues", coral→"Corail", ore→"Minerai", energy→"Énergie", pearl→"Perles"

## Dependencies

- None (standalone widget, but will be wired in task 10)

## Test Plan

- **File:** `test/presentation/widgets/map/treasure_sheet_test.dart`
- Test: resourceBonus shows resource type and amount
- Test: ruins shows random reward description
- Test: "Collecter le trésor" button is displayed
- Test: tapping button calls onCollect callback

## Notes

- Follows `ExplorationSheet` visual patterns (padding, text styles, layout).
- The `_infoRow` helper can be extracted if shared with other sheets, but for now keep it inline.
