# Improve Zoom — Feature Specification

## 1. Feature Overview

- Allow the player to zoom in much further on the game map, up to a single cell filling the entire screen.
- Currently the maximum zoom shows 4 cells; this change increases it to 1 cell visible at max zoom.
- The default zoom level at map opening (8 cells visible) remains unchanged.
- No additional detail is displayed at higher zoom levels — the existing cell content simply scales up.

## 2. User Stories

### US-1: Zoom in to a single cell

**As a** player
**I want** to zoom in until a single cell fills my screen
**So that** I can clearly see the content of any cell on the map

**Acceptance criteria:**
- The maximum zoom level allows 1 cell to be visible on screen (instead of the current 4).
- Pinch-to-zoom and scroll-wheel zoom both reach the new maximum.
- The map remains pannable at all zoom levels.
- The zoom-out limit (full map visible) is unchanged.

### US-2: Default zoom unchanged

**As a** player
**I want** the map to open at the same zoom level as before
**So that** my initial view of the map is familiar and unchanged

**Acceptance criteria:**
- The map still opens showing 8 cells by default, centered on the player base.

## 3. Testing and Validation

- **Unit tests**: Verify that the computed `maxScale` corresponds to 1 visible cell for a given screen width.
- **Widget tests**: Confirm `InteractiveViewer` is configured with the correct `minScale` / `maxScale` bounds.
- **Manual testing**: On iOS, Android, and Web — pinch/scroll to max zoom and verify a single cell fills the screen, panning works correctly, and the default opening zoom is unchanged.
- **Criteria for success**: All existing map tests pass; new zoom limit is enforced; no visual regression at other zoom levels.
