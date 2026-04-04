# Task 17: Widget Tests — UnitDetailSheet and RecruitmentSection

## Summary

Write widget tests for the unit detail bottom sheet and recruitment slider section.

## Implementation Steps

### 1. Create `test/presentation/widgets/unit_detail_sheet_test.dart`

Setup: `mockSvgAssets()` / `clearSvgMocks()`, `_useTallSurface()`

Helper: create app with button that calls `showUnitDetailSheet(...)`

**Locked unit tests:**
- Shows unit name
- Shows "Caserne niveau X requise pour debloquer" (e.g., X=1 for scout)
- Does NOT show stats (no 'PV:', 'ATQ:', 'DEF:')
- Does NOT show slider

**Unlocked unit tests:**
- Shows unit name
- Shows stats: 'PV: 10', 'ATQ: 2', 'DEF: 1' for scout
- Shows current count
- Shows recruitment section (slider present)

### 2. Create `test/presentation/widgets/recruitment_section_test.dart`

Setup: `mockSvgAssets()` / `clearSvgMocks()`

- Slider max matches `maxRecruitableCount`
- Recruit button is disabled when slider value is 0
- "Recrutement deja effectue ce tour" shown when `hasRecruitedThisType = true`
- "Ressources insuffisantes" shown when `maxRecruitableCount = 0`
- Moving slider updates displayed quantity
- Tapping recruit calls `onRecruit` with current slider value

## Dependencies

- Tasks 11, 12 (UnitDetailSheet, RecruitmentSection)

## Test Plan

This IS the test task. Files listed above.

## Notes

- Use `_useTallSurface()` for bottom sheet tests (same as building_detail_sheet_test).
- Use `tester.drag(find.byType(Slider), Offset(100, 0))` to move slider in tests.
- Follow patterns from `building_detail_sheet_test.dart`.
