import 'package:flutter/material.dart';
import '../../../domain/action/action_executor.dart';
import '../../../domain/action/research_tech_action.dart';
import '../../../domain/action/unlock_branch_action.dart';
import '../../../domain/game/game.dart';
import '../../../domain/tech/tech_branch.dart';

void unlockBranch(Game game, TechBranch branch, VoidCallback onChanged) {
  final action = UnlockBranchAction(branch: branch);
  final result = ActionExecutor().execute(action, game, game.humanPlayer);
  if (result.isSuccess) onChanged();
}

void researchTech(Game game, TechBranch branch, VoidCallback onChanged) {
  final action = ResearchTechAction(branch: branch);
  final result = ActionExecutor().execute(action, game, game.humanPlayer);
  if (result.isSuccess) onChanged();
}
