# Task 12: Create RecruitmentSection Widget

## Summary

Create the `RecruitmentSection` widget with a slider to choose quantity, dynamic cost display, and a recruit button. Handles disabled states for "already recruited" and "cannot afford".

## Implementation Steps

### 1. Create `lib/presentation/widgets/recruitment_section.dart`

Class `RecruitmentSection extends StatefulWidget`:

Props:
- `UnitType unitType`
- `int maxRecruitableCount` (pre-computed by caller)
- `bool hasRecruitedThisType`
- `void Function(int quantity) onRecruit`

State:
- `int _sliderValue = 0`

Build:

**If `hasRecruitedThisType`:**
- Show `Text('Recrutement deja effectue ce tour')` in `AbyssColors.warning`
- Slider and button are disabled

**If `maxRecruitableCount == 0`:**
- Show `Text('Ressources insuffisantes')` in `AbyssColors.disabled`
- Slider and button are disabled

**Otherwise:**
- `Slider` with min=0, max=`maxRecruitableCount.toDouble()`, divisions=max
- Label showing current value: `Text('$_sliderValue unites')`
- Cost display: for each resource in `recruitmentCost`, show icon + `${cost * _sliderValue}` — use resource color for styling
- `ElevatedButton('Recruter')` enabled only when `_sliderValue > 0`
- On button press: call `onRecruit(_sliderValue)`

## Dependencies

- Task 03 (UnitCostCalculator for `recruitmentCost`)
- Existing: ResourceType extensions (for resource icons/names in cost display)

## Test Plan

- **File**: `test/presentation/widgets/recruitment_section_test.dart`
  - Slider max matches `maxRecruitableCount`
  - Cost updates when slider moves
  - Button disabled when slider is 0
  - "Recrutement deja effectue ce tour" shown when `hasRecruitedThisType`
  - "Ressources insuffisantes" shown when `maxRecruitableCount == 0`
  - Button tap calls `onRecruit` with slider value

## Notes

- The slider uses `divisions` for integer steps (snap to whole numbers).
- Cost display uses `ResourceIcon` from existing widgets.
- `maxRecruitableCount` is computed by the caller using `UnitCostCalculator().maxRecruitableCount(...)` — keeps this widget stateless in terms of domain logic.
