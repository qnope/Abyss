import 'resource.dart';
import 'resource_type.dart';

/// Gains added to a stock of resources, each capped by its storage.
abstract final class ResourceCredit {
  /// Adds [amounts] to [resources], each up to its `maxStorage`, and
  /// returns what was actually added by type: 0 for a resource missing
  /// from [resources].
  static Map<ResourceType, int> add(
    Map<ResourceType, Resource> resources,
    Map<ResourceType, int> amounts,
  ) {
    final added = <ResourceType, int>{};
    for (final entry in amounts.entries) {
      final resource = resources[entry.key];
      if (resource == null) {
        added[entry.key] = 0;
        continue;
      }
      final before = resource.amount;
      resource.amount = (before + entry.value).clamp(0, resource.maxStorage);
      added[entry.key] = resource.amount - before;
    }
    return added;
  }
}
