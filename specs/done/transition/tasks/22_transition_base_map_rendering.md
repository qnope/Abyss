# Task 22: Add Transition Base Rendering to MapCellWidget

## Summary
Update the map cell rendering to display transition bases in their 3 visual states: hidden (fog), discovered-not-captured (red glow), captured (cyan glow).

## Implementation Steps

1. **Update MapCellWidget** in `lib/presentation/widgets/map/map_cell_widget.dart`:
   - When `cell.content == CellContentType.transitionBase`:
     - **Discovered, not captured**: rift icon with red pulsing glow + danger halo
     - **Captured by player**: rift icon with cyan glow
   - When cell is under fog of war: normal fog tile (no change)

2. **Create rift icon**:
   - Use an icon or custom painting for the rift/faille visual
   - Could use `Icons.electric_bolt` or similar as placeholder
   - Faille: vertical rift icon
   - Cheminee: volcanic vent icon (if different)

3. **Glow effect**:
   - Not captured: `Container` with `BoxDecoration(boxShadow: [red glow])` or use `DecoratedBox` with `AbyssColors.dangerRed` glow
   - Captured: same but with `AbyssColors.biolumCyan`
   - Pulsing animation for uncaptured: use `AnimatedContainer` or `AnimationController` with periodic opacity

4. **Aura colors** (per US-2):
   - Player owns: green aura → use `AbyssColors.biolumCyan` (our captured state)
   - Monster owns: red aura
   - Other player: orange aura (future, not implemented now)

## Dependencies
- **Internal**: Task 07 (TransitionBase model on MapCell)
- **External**: AbyssTheme, MapCellWidget (existing)

## Test Plan
- **File**: `test/presentation/widgets/map/map_cell_widget_test.dart`
  - Verify transition base cell with `capturedBy == null` shows red glow
  - Verify transition base cell with `capturedBy == playerId` shows cyan glow
  - Verify normal cells unchanged
- Run `flutter analyze`

## Notes
- Keep changes to MapCellWidget minimal. If the widget is near the 150-line limit, extract a `TransitionBaseCellOverlay` sub-widget.
- The pulsing animation is optional for V1 — a static glow is acceptable.
