# Task 07 — Create ResourceIcon widget

## Summary

Create a reusable `ResourceIcon` widget that renders a resource SVG icon given a resource type and size. This widget encapsulates the mapping between resource types and SVG asset paths.

## Implementation Steps

1. **Create file** `lib/presentation/widgets/resource_icon.dart`.

2. **Widget definition**:
   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_svg/flutter_svg.dart';

   enum ResourceType { algae, coral, ore, energy, pearl }

   class ResourceIcon extends StatelessWidget {
     final ResourceType type;
     final double size;

     const ResourceIcon({
       super.key,
       required this.type,
       this.size = 24,
     });

     String get _assetPath =>
       'assets/icons/resources/${type.name}.svg';

     @override
     Widget build(BuildContext context) {
       return SvgPicture.asset(
         _assetPath,
         width: size,
         height: size,
       );
     }
   }
   ```

3. **Key design decisions**:
   - `ResourceType` enum lives here for now; it will be moved to domain layer when the resource system is built.
   - Default size is 24px (resource bar usage).
   - Asset path derived from enum name (matches SVG filenames: `algae.svg`, `coral.svg`, etc.).

## Dependencies

- Task 01 (flutter_svg dependency).
- Tasks 02-06 (SVG files must exist for runtime rendering, but widget can be coded before).

## Test Plan

- **Test file**: `test/presentation/widgets/resource_icon_test.dart`
- **Test cases**:
  1. Widget builds without error for each `ResourceType`.
  2. Correct asset path is generated for each type.
  3. Custom size is applied correctly.

## Notes

- Keep the widget simple — no color overrides or animation for now.
- The enum may move to the domain layer in a future resource-system project; that's fine, this is the first usage.
- File should be well under 150 lines.
