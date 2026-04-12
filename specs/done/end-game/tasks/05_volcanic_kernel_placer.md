# Task 5: Place volcanic kernel at center of Level 3 map

## Summary

Create `VolcanicKernelPlacer` to place a single volcanic kernel cell at the center of Level 3, and integrate it into `MapGenerator`.

## Implementation Steps

### 1. Create `lib/domain/map/volcanic_kernel_placer.dart`

```dart
class VolcanicKernelPlacer {
  static void place({
    required List<MapCell> cells,
    required int width,
    required int height,
  }) {
    final centerX = width ~/ 2;
    final centerY = height ~/ 2;
    final index = centerY * width + centerX;
    cells[index] = cells[index].copyWith(
      content: CellContentType.volcanicKernel,
      lair: null,
      transitionBase: null,
    );
  }
}
```

The volcanic kernel is always placed at position (10, 10) on a 20x20 map (center = size ~/ 2).

### 2. Edit `lib/domain/map/map_generator.dart`

Add import:
```dart
import 'volcanic_kernel_placer.dart';
```

After the `TransitionBasePlacer.place()` call, add:
```dart
if (level == 3) {
  VolcanicKernelPlacer.place(
    cells: cells,
    width: _size,
    height: _size,
  );
}
```

This replaces whatever content was at the center with the volcanic kernel.

## Dependencies

- Task 1: `CellContentType.volcanicKernel` must exist
- Task 4: `build_runner` must have been run

## Test Plan

- **File**: `test/domain/map/volcanic_kernel_placer_test.dart`
- Test: placing on a 20x20 map puts `volcanicKernel` at index `10 * 20 + 10 = 210`
- Test: the cell at (10, 10) has `content == CellContentType.volcanicKernel`
- Test: only one cell in the map has `volcanicKernel` content
- **File**: `test/domain/map/map_generator_test.dart` (add test)
- Test: `MapGenerator.generate(level: 3)` produces a map with exactly one `volcanicKernel` cell at the center
- Test: `MapGenerator.generate(level: 1)` and `level: 2` do NOT contain any `volcanicKernel` cell

## Notes

- The volcanic kernel overwrites any content that `ContentPlacer` may have placed at center. This is intentional — the center is reserved for the kernel on Level 3.
- No `reservedIndices` check needed since the kernel is placed after all other placers.
