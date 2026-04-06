# Resource Bar Readability - Feature Specification

## 1. Feature Overview

The resource bar at the top of the game screen becomes hard to read when resources have both production and consumption values (e.g., `+8/-2/t`). Everything is crammed on a single horizontal line per resource.

This feature changes the layout of each resource bar item from a single-line horizontal display to a two-line stacked layout, improving readability.

**Current layout (single line):**
```
[Icon] 150 +8/-2/t    [Icon] 80 +3/t    [Icon] 200 +5/t
```

**New layout (two lines):**
```
[Icon] 150          [Icon] 80          [Icon] 200
  +8/-2/t             +3/t               +5/t
```

## 2. User Stories

### US1: Resource rate on a separate line
**As a** player,
**I want** the production/consumption rate displayed on a second line below the resource amount,
**So that** I can read both the amount and the rate clearly, even with many resources.

**Acceptance criteria:**
- Line 1 displays the resource icon and the current amount.
- Line 2 displays the production/consumption rate text (e.g., `+8/-2/t` or `+3/t`).
- The rate text is horizontally centered under the icon + amount.
- The existing color logic is preserved: red when consumption > production, otherwise resource color at 70% opacity.

### US2: Consistent layout when no rate exists
**As a** player,
**I want** all resource items to have the same height in the bar,
**So that** the bar looks aligned and uniform regardless of which resources have production.

**Acceptance criteria:**
- When a resource has production or consumption, line 2 shows the rate text.
- When a resource has neither production nor consumption (e.g., pearl), line 2 is an empty space of the same height.
- All resource items in the bar have uniform height.

### US3: Always use two-line layout
**As a** player,
**I want** the two-line layout to be used even when there is only production (no consumption),
**So that** the alignment stays consistent across all resources.

**Acceptance criteria:**
- Even if only production is present (e.g., `+3/t`), the rate is displayed on line 2.
- The layout does not switch between one-line and two-line depending on the data.

## 3. Testing and Validation

- **Unit tests:** Update existing `ResourceBarItem` widget tests to verify:
  - The rate text appears below (not beside) the amount.
  - Uniform height is maintained when rate is absent.
  - Color logic remains unchanged.
- **Widget tests:** Verify the `ResourceBar` renders correctly with the new two-line layout.
- Run `flutter analyze` and `flutter test` to ensure no regressions.
