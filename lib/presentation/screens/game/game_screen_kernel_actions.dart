import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/action/action_executor.dart';
import '../../../domain/action/garrison_kernel_action.dart';
import '../../../domain/game/game.dart';
import '../../../domain/map/map_cell.dart';
import '../../../domain/objective/guide/guide_advisor.dart';
import '../../../domain/volcano/kernel_garrison.dart';
import '../../extensions/action_failure_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../widgets/map/volcanic_kernel_sheet.dart';
import '../../widgets/unit/unit_picker_dialog.dart';
import 'fight/kernel_army_selection_screen.dart';
import 'game_screen_assault_plan.dart';

/// Opens the sheet of the volcanic kernel at ([x], [y]) on [level]: the
/// plan of an assault on it, or its garrison once [isCaptured].
void openVolcanicKernelSheet(
  BuildContext context,
  Game game,
  GameRepository repository,
  int x,
  int y,
  int level, {
  required bool isCaptured,
  required VoidCallback onChanged,
}) {
  showVolcanicKernelSheet(
    context,
    isCaptured: isCaptured,
    player: game.humanPlayer,
    level: level,
    assaultPlan: isCaptured ? null : assaultPlanAt(game, level, x, y),
    garrisonGuided: isGarrisonGuided(game),
    onAttack: () => handleAttackVolcanicKernel(
        context, game, repository, x, y, level, onChanged),
    onGarrison: () =>
        handleGarrisonKernel(context, game, repository, onChanged),
    onWithdraw: () => handleGarrisonKernel(
        context, game, repository, onChanged, withdraw: true),
  );
}

/// Whether the guide asks the human player of [game] to fill the
/// kernel's garrison: its sheets then surround the button.
bool isGarrisonGuided(Game game) =>
    GuideAdvisor.of(game, game.humanPlayer)?.target.garrison ?? false;

void handleAttackVolcanicKernel(
  BuildContext context,
  Game game,
  GameRepository repository,
  int x,
  int y,
  int level,
  VoidCallback onChanged,
) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => KernelArmySelectionScreen(
        game: game,
        repository: repository,
        targetX: x,
        targetY: y,
        level: level,
        onChanged: onChanged,
      ),
    ),
  );
}

/// Opens the unit picker that moves units from the volcano level into the
/// kernel's garrison, or back out when [withdraw] is set.
Future<void> handleGarrisonKernel(
  BuildContext context,
  Game game,
  GameRepository repository,
  VoidCallback onChanged, {
  bool withdraw = false,
}) async {
  final player = game.humanPlayer;
  final l10n = context.l10n;
  final picked = await showUnitPickerDialog(
    context,
    title: withdraw
        ? l10n.screenGarrisonWithdrawTitle
        : l10n.screenGarrisonSendTitle,
    availableUnits: player.unitsOnLevel(
      withdraw ? KernelGarrison.stockKey : KernelGarrison.volcanoLevel,
    ),
    confirmLabel: withdraw ? l10n.screenGarrisonWithdraw : l10n.commonSend,
    info: withdraw
        ? l10n.screenGarrisonWithdrawInfo
        : l10n.screenGarrisonSendInfo,
  );
  if (picked == null) return;
  final result = ActionExecutor().execute(
    GarrisonKernelAction(selectedUnits: picked, withdraw: withdraw),
    game,
    player,
  );
  if (result.isSuccess) await repository.save(game);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(result.isSuccess
        ? l10n.screenGarrisonSize(KernelGarrison.sizeOf(player))
        : result.failureMessage(l10n)),
  ));
  onChanged();
}

/// Whether another player than the human holds the kernel of [cell].
bool isKernelHeldByRival(Game game, MapCell cell) =>
    cell.collectedBy != null &&
    cell.collectedBy != game.humanPlayerId &&
    game.players[cell.collectedBy] != null;
