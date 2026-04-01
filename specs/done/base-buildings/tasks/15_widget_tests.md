# Task 15 — Widget Tests

## Summary

Write widget tests for all new presentation widgets and the updated GameScreen.

## Implementation Steps

### 1. Create `test/presentation/widgets/building_icon_test.dart`

Test cases:
- Renders an SvgPicture
- Uses correct asset path for headquarters
- Default size is 24
- Custom size is applied
- Greyscale mode applies a ColorFilter

Setup: call `mockSvgAssets()` in setUp, `clearSvgMocks()` in tearDown.

### 2. Create `test/presentation/widgets/building_card_test.dart`

Test cases:
- Displays building name ("Quartier Général")
- Displays level ("Niveau 3") for a built building
- Displays "Non construit" for level 0
- Card is visually dimmed (Opacity) when level 0
- Calls onTap callback when tapped

Setup: wrap in `MaterialApp` with `AbyssTheme`, call `mockSvgAssets()`.

### 3. Create `test/presentation/widgets/building_list_view_test.dart`

Test cases:
- Displays one BuildingCard per building
- Calls onBuildingTap with correct building when card is tapped

### 4. Create `test/presentation/widgets/building_detail_sheet_test.dart`

Test cases:
- Shows building name and level
- Shows building description
- Shows upgrade costs with resource icons
- Upgrade button is enabled when resources are sufficient
- Upgrade button is disabled when resources are insufficient
- Shows "Niveau maximum atteint" when at max level
- Shows "Construire" button label when level is 0
- Shows "Améliorer" button label when level > 0
- Insufficient resources are displayed in red (error color)

Setup: call `showBuildingDetailSheet(...)` within a `MaterialApp`, use `mockSvgAssets()`.

### 5. Update `test/presentation/screens/game_screen_test.dart`

Add test cases:
- Base tab shows BuildingListView (not TabPlaceholder)
- Tapping a building card opens the BuildingDetailSheet
- After upgrade: building level increases and resources decrease
- ResourceBar reflects updated resource amounts after upgrade

## Files

| Action | Path |
|--------|------|
| Create | `test/presentation/widgets/building_icon_test.dart` |
| Create | `test/presentation/widgets/building_card_test.dart` |
| Create | `test/presentation/widgets/building_list_view_test.dart` |
| Create | `test/presentation/widgets/building_detail_sheet_test.dart` |
| Modify | `test/presentation/screens/game_screen_test.dart` |

## Dependencies

- Tasks 09–14 (all presentation widgets and wiring)
- Task 07 (domain tests should pass first)

## Test Plan

Run: `flutter test test/presentation/`

All tests must pass. Run `flutter analyze` to confirm no warnings.

## Notes

- Follow existing test patterns in `test/presentation/widgets/resource_icon_test.dart` and `resource_bar_item_test.dart`
- Always use `mockSvgAssets()` / `clearSvgMocks()` when SVG icons are rendered
- Use `FakeGameRepository` for GameScreen tests
- Create helper functions for building test data (Game with specific resources/buildings) to keep tests concise
- Wrap widgets in `MaterialApp(theme: AbyssTheme.dark())` for proper theme resolution
