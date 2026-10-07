import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/resource/resource.dart';
import '../../../domain/resource/resource_type.dart';
import '../../../domain/tech/tech_branch.dart';
import '../../../domain/tech/tech_branch_state.dart';
import 'tech_reef.dart';
import 'tech_selection.dart';
import 'tech_selection_panel.dart';

/// Laboratory screen: the radial research reef above a panel to unlock
/// or research whatever is selected in it.
class TechTreeView extends StatefulWidget {
  final Map<TechBranch, TechBranchState> techBranches;
  final Map<BuildingType, Building> buildings;
  final Map<ResourceType, Resource> resources;
  final void Function(TechBranch branch) onUnlock;
  final void Function(TechBranch branch) onResearch;

  const TechTreeView({
    super.key,
    required this.techBranches,
    required this.buildings,
    required this.resources,
    required this.onUnlock,
    required this.onResearch,
  });

  @override
  State<TechTreeView> createState() => _TechTreeViewState();
}

class _TechTreeViewState extends State<TechTreeView> {
  /// Room kept under the reef for the selection panel.
  static const _panelSpace = 150.0;
  static const _minReefHeight = 380.0;

  late TechSelection _selection =
      TechSelection.suggested(widget.techBranches);

  int get _labLevel =>
      widget.buildings[BuildingType.laboratory]?.level ?? 0;

  void _act() {
    final branch = _selection.branch;
    if (_selection.level == null) {
      widget.onUnlock(branch);
    } else {
      widget.onResearch(branch);
    }
    setState(() => _selection = _selection.next);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final reefHeight =
          math.max(box.maxHeight - _panelSpace, _minReefHeight);
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(children: [
          SizedBox(
            height: reefHeight,
            child: TechReef(
              techBranches: widget.techBranches,
              labLevel: _labLevel,
              selection: _selection,
              onSelect: (s) => setState(() => _selection = s),
            ),
          ),
          const SizedBox(height: 8),
          TechSelectionPanel(
            selection: _selection,
            techBranches: widget.techBranches,
            buildings: widget.buildings,
            resources: widget.resources,
            onAct: _act,
          ),
        ]),
      );
    });
  }
}
