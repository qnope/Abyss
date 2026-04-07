# Task 09 — Update MapCellWidget for greyed-out collected cells

## Summary

When a cell has `isCollected == true`, its content icon should remain visible but appear greyed out (reduced opacity) to visually indicate the treasure has already been collected.

## Implementation Steps

1. **Edit `lib/presentation/widgets/map/map_cell_widget.dart`**

   - In `_contentLayer()`, wrap the `SvgPicture` in an `Opacity` widget when the cell is collected:
     ```dart
     Widget _contentLayer() {
       final path = _contentSvgPath;
       if (path == null) return const SizedBox.shrink();
       final icon = Center(
         child: SvgPicture.asset(path, width: _contentSize, height: _contentSize),
       );
       if (cell.isCollected) {
         return Opacity(opacity: 0.3, child: icon);
       }
       return icon;
     }
     ```

## Dependencies

- Task 01 (`isCollected` field on MapCell)

## Test Plan

- **File:** `test/presentation/widgets/map/map_cell_widget_test.dart`
- Add test: `'collected cell shows content with reduced opacity'`
  - Create a MapCell with `isCollected: true`, `content: resourceBonus`, `isRevealed: true`
  - Pump `MapCellWidget`
  - Find `Opacity` widget, verify `opacity == 0.3`
- Add test: `'non-collected cell shows content without opacity wrapper'`
  - Create a MapCell with `isCollected: false`, `content: resourceBonus`, `isRevealed: true`
  - Pump `MapCellWidget`
  - Verify no `Opacity` widget wrapping content

## Notes

- Using `Opacity(opacity: 0.3)` is the simplest approach. Could also use `ColorFiltered` with a greyscale matrix, but opacity is sufficient per spec ("opacité réduite ou désaturation").
- The file stays well under 150 lines with this change.
