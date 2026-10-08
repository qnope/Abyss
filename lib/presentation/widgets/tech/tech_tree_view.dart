import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/resource/resource.dart';
import '../../../domain/resource/resource_type.dart';
import '../../../domain/tech/tech_branch.dart';
import '../../../domain/tech/tech_branch_state.dart';
import '../../../domain/tech/tech_option.dart';
import 'tech_reef.dart';
import 'tech_target.dart';
import 'tech_target_panel.dart';

/// Laboratory screen: the radial research reef. Tapping a branch or a
/// node opens a popup to unlock or research it.
class TechTreeView extends StatelessWidget {
  static const _minReefHeight = 560.0;

  final Map<TechBranch, TechBranchState> techBranches;
  final Map<BuildingType, Building> buildings;
  final Map<ResourceType, Resource> resources;
  final bool researchDone;
  final void Function(TechBranch branch) onUnlock;
  final void Function(TechBranch branch, TechOption option) onResearch;

  const TechTreeView({
    super.key,
    required this.techBranches,
    required this.buildings,
    required this.resources,
    this.researchDone = false,
    required this.onUnlock,
    required this.onResearch,
  });

  int get _labLevel => buildings[BuildingType.laboratory]?.level ?? 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: math.max(box.maxHeight - 24, _minReefHeight),
          child: TechReef(
            techBranches: techBranches,
            labLevel: _labLevel,
            onTap: (target) => _openPopup(context, target),
          ),
        ),
      );
    });
  }

  void _openPopup(BuildContext context, TechTarget target) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TechTargetPanel(
            target: target,
            techBranches: techBranches,
            buildings: buildings,
            resources: resources,
            researchDone: researchDone,
            onAct: (option) {
              _act(target, option);
              Navigator.pop(sheetContext);
            },
          ),
        ]),
      ),
    );
  }

  void _act(TechTarget target, TechOption option) {
    if (target.level == null) {
      onUnlock(target.branch);
    } else {
      onResearch(target.branch, option);
    }
  }
}
