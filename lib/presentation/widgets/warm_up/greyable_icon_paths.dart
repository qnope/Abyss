import '../../../domain/building/building_type.dart';
import '../../../domain/tech/tech_branch.dart';
import '../../../domain/tech/tech_option.dart';
import '../../../domain/tech/tech_tree.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/building_type_extensions.dart';
import '../../extensions/tech_branch_extensions.dart';
import '../../extensions/tech_node_extensions.dart';
import '../../extensions/unit_type_extensions.dart';

/// Every icon a screen may draw in greyscale: unbuilt buildings, locked
/// units, locked branches and every research node.
List<String> greyableIconPaths() => {
  for (final type in BuildingType.values) type.iconPath,
  for (final type in UnitType.values) type.iconPath,
  for (final branch in TechBranch.values) ...[
    branch.iconPath,
    for (var level = 1; level <= TechTree.maxLevel; level++)
      if (TechTree.isChoiceLevel(level))
        for (final option in TechOption.values)
          branch.nodeIconPath(level, option)
      else
        branch.nodeIconPath(level),
  ],
}.toList();
