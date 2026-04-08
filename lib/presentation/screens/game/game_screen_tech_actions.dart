import 'package:flutter/material.dart';
import '../../../domain/action/action_executor.dart';
import '../../../domain/game/game.dart';
import '../../../domain/action/research_tech_action.dart';
import '../../../domain/tech/tech_branch.dart';
import '../../../domain/action/unlock_branch_action.dart';
import '../../widgets/tech/tech_branch_detail_sheet.dart';
import '../../widgets/tech/tech_node_detail_sheet.dart';

void showBranchDetail(BuildContext context, Game game, TechBranch branch,
    VoidCallback onChanged) {
  final human = game.humanPlayer;
  showTechBranchDetailSheet(
    context,
    branch: branch,
    state: human.techBranches[branch]!,
    resources: human.resources,
    buildings: human.buildings,
    onUnlock: () => _unlockBranch(context, game, branch, onChanged),
  );
}

void _unlockBranch(BuildContext context, Game game, TechBranch branch,
    VoidCallback onChanged) {
  final action = UnlockBranchAction(branch: branch);
  final result = ActionExecutor().execute(action, game, game.humanPlayer);
  if (result.isSuccess) {
    onChanged();
    Navigator.pop(context);
  }
}

void showNodeDetail(BuildContext context, Game game, TechBranch branch,
    int level, VoidCallback onChanged) {
  final human = game.humanPlayer;
  showTechNodeDetailSheet(
    context,
    branch: branch,
    level: level,
    state: human.techBranches[branch]!,
    resources: human.resources,
    buildings: human.buildings,
    onResearch: () => _researchTech(context, game, branch, onChanged),
  );
}

void _researchTech(BuildContext context, Game game, TechBranch branch,
    VoidCallback onChanged) {
  final action = ResearchTechAction(branch: branch);
  final result = ActionExecutor().execute(action, game, game.humanPlayer);
  if (result.isSuccess) {
    onChanged();
    Navigator.pop(context);
  }
}
