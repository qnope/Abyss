# Game Screen Layout - Feature Specification

## 1. Feature Overview

Redesign the main game screen to replace the current placeholder with a functional layout composed of three zones:

1. **Resource Bar (top)** - A compact horizontal bar displaying all 5 resources with their current amounts and production rates, replacing the current AppBar.
2. **Bottom Navigation Bar** - Tab-based navigation (Base, Map, Army, Tech) with integrated turn number and "Next Turn" button.
3. **Main Content Area** - Placeholder content area that will later host each tab's content.

## 2. User Stories

### US-1: View resources at a glance
**As a** player,
**I want** to see all my resources and their production rates at the top of the screen,
**So that** I can make informed decisions about my next actions.

**Acceptance Criteria:**
- The resource bar is displayed at the top of the screen, replacing the AppBar.
- Each of the 4 production resources (Algae, Coral, Ore, Energy) shows: icon + current amount + production rate per turn (e.g., `+12/t`).
- Pearl is displayed with a visual separator (small divider or extra gap) to distinguish it as a rare resource.
- Pearl shows only icon + current amount (no production rate, since it is found by exploration, not produced by buildings).
- Resource icons use the existing `ResourceIcon` widget and bioluminescent SVG assets.
- Text colors match each resource's theme color from `AbyssColors`.

### US-2: See resource changes on new turn
**As a** player,
**I want** visual feedback when my resources change after pressing "Next Turn",
**So that** I immediately notice gains and losses.

**Acceptance Criteria:**
- When a resource amount increases, the number briefly flashes green (~0.5s).
- When a resource amount decreases, the number briefly flashes red (~0.5s).
- The flash is subtle (color change only, no size or position animation).

### US-3: View resource details
**As a** player,
**I want** to tap on a resource to see detailed information,
**So that** I can understand where my production comes from.

**Acceptance Criteria:**
- Tapping a resource in the bar opens a bottom sheet.
- The bottom sheet displays:
  - Resource name and icon (large).
  - Flavor description of the resource.
  - Current amount and storage capacity (e.g., `150 / 500`).
  - Production breakdown: list of buildings contributing to production, with each building's contribution.
- The bottom sheet can be dismissed by swiping down or tapping outside.
- Note: production breakdown data may show placeholder/mock data until the building system is implemented.

### US-4: Navigate between game sections
**As a** player,
**I want** to switch between Base, Map, Army, and Tech views using bottom tabs,
**So that** I can manage different aspects of my civilization.

**Acceptance Criteria:**
- A bottom navigation bar displays 4 tabs: Base, Map, Army, Tech.
- Each tab has an icon and label.
- The currently selected tab is visually highlighted (bioluminescent glow or accent color).
- Switching tabs changes the main content area.
- The current turn number is displayed in the bottom bar (e.g., left side or center above tabs).
- A prominent "Next Turn" button is integrated into the bottom bar.

### US-5: Save and quit
**As a** player,
**I want** to access save and quit options from the game screen,
**So that** I can preserve my progress and exit.

**Acceptance Criteria:**
- Save/quit actions are accessible via a menu (e.g., long-press on a tab, or a settings icon in one of the tabs).
- The existing save-and-quit functionality is preserved.

### US-6: See placeholder content
**As a** player,
**I want** each tab to show a placeholder indicating what will be there,
**So that** the game screen feels structured even before all features are built.

**Acceptance Criteria:**
- Each tab (Base, Map, Army, Tech) shows a centered placeholder with:
  - An icon representing the section.
  - A short text (e.g., "Base - Coming soon").
- The placeholder uses the existing Abyss theme styling.

## 3. Testing and Validation

### Unit Tests
- `ResourceBar` widget renders all 5 resources with correct icons.
- Pearl is visually separated from the 4 production resources.
- Tapping a resource triggers the bottom sheet.
- `ResourceDetailSheet` displays correct resource information.
- Bottom navigation bar renders 4 tabs.
- Tab selection changes the displayed content.
- Turn number is displayed in the bottom bar.
- Flash animation triggers on resource value changes.

### Widget Tests
- Full `GameScreen` layout integrates resource bar, content area, and bottom bar.
- Navigation between tabs works correctly.
- Save/quit flow remains functional.

### Manual Testing
- Verify layout on different screen sizes (phone portrait, phone landscape, tablet).
- Verify resource icons render correctly with their SVGs.
- Verify the bioluminescent theme is consistent across all new elements.
