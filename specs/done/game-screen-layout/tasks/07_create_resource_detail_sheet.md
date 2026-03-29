# Task 07: Create ResourceDetailSheet widget

## Summary

Create a bottom sheet that displays detailed information about a resource when tapped in the resource bar: large icon, name, flavor description, current amount vs. max storage, and a placeholder production breakdown.

## Implementation Steps

### Step 1: Create `lib/presentation/widgets/resource_detail_sheet.dart`

Expose a top-level function `showResourceDetailSheet(BuildContext, Resource)` and a private `_ResourceDetailSheet` widget.

```dart
import 'package:flutter/material.dart';
import '../../domain/resource.dart';
import '../../domain/resource_type.dart';
import '../theme/abyss_colors.dart';
import 'resource_bar_item.dart'; // for ResourceTypeColor extension
import 'resource_icon.dart';

void showResourceDetailSheet(BuildContext context, Resource resource) {
  showModalBottomSheet<void>(
    context: context,
    builder: (_) => _ResourceDetailSheet(resource: resource),
  );
}

class _ResourceDetailSheet extends StatelessWidget {
  final Resource resource;
  const _ResourceDetailSheet({required this.resource});

  @override
  Widget build(BuildContext context) {
    final color = resource.type.color;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ResourceIcon(type: resource.type, size: 64),
          const SizedBox(height: 12),
          Text(resource.type.displayName, style: textTheme.headlineSmall?.copyWith(color: color)),
          const SizedBox(height: 8),
          Text(resource.type.flavorText, style: textTheme.bodyMedium?.copyWith(color: AbyssColors.onSurfaceDim), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          // Amount / capacity
          Text('${resource.amount} / ${resource.maxStorage}', style: textTheme.titleLarge?.copyWith(color: color)),
          const SizedBox(height: 16),
          // Production breakdown (placeholder)
          if (resource.productionPerTurn > 0) ...[
            Align(alignment: Alignment.centerLeft, child: Text('Production', style: textTheme.titleSmall?.copyWith(color: AbyssColors.onSurface))),
            const SizedBox(height: 8),
            _buildingRow('Bâtiment principal', resource.productionPerTurn, color),
          ],
        ],
      ),
    );
  }

  Widget _buildingRow(String name, int amount, Color color) {
    return Row(
      children: [
        Icon(Icons.home, size: 16, color: AbyssColors.onSurfaceDim),
        const SizedBox(width: 8),
        Expanded(child: Text(name, style: TextStyle(color: AbyssColors.onSurfaceDim))),
        Text('+$amount/t', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
```

### Step 2: Add display name and flavor text extensions

Add to `resource_bar_item.dart` (extending the existing `ResourceTypeColor` extension) or create a combined extension:

```dart
extension ResourceTypeInfo on ResourceType {
  String get displayName => switch (this) {
    ResourceType.algae => 'Algues',
    ResourceType.coral => 'Corail',
    ResourceType.ore => 'Minerai',
    ResourceType.energy => 'Énergie',
    ResourceType.pearl => 'Perles',
  };

  String get flavorText => switch (this) {
    ResourceType.algae => 'Nourriture cultivée dans les fermes sous-marines pour nourrir vos unités.',
    ResourceType.coral => 'Matériau de construction récolté sur les récifs pour bâtir votre base.',
    ResourceType.ore => 'Métal extrait des profondeurs pour forger des équipements avancés.',
    ResourceType.energy => 'Énergie captée pour alimenter vos bâtiments et machines.',
    ResourceType.pearl => 'Gemmes rares découvertes lors d\'explorations, essentielles aux technologies avancées.',
  };
}
```

**Decision:** Put both `ResourceTypeColor` and `ResourceTypeInfo` extensions in a new file `lib/presentation/extensions/resource_type_extensions.dart` to keep things clean and reusable. Update imports in `resource_bar_item.dart`.

## Dependencies

- Task 02 (Resource model).
- Task 05 (ResourceBarItem — for the color extension, or shared extensions file).

## Test Plan

- **File:** `test/presentation/widgets/resource_detail_sheet_test.dart` (Task 12)
- Test: Sheet displays resource name and icon.
- Test: Sheet displays amount / maxStorage.
- Test: Sheet shows production breakdown for production resources.
- Test: Sheet hides production for Pearl.

## Notes

- Production breakdown uses placeholder data ("Bâtiment principal") until buildings are implemented (per SPEC.md US-3).
- The bottom sheet theme from `AbyssCardTheme.bottomSheet()` is already configured with drag handle and rounded corners.
- File should stay well under 150 lines.
