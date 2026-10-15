import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/action/action_executor.dart';
import '../../../domain/action/attack_volcanic_kernel_result.dart';
import '../../../domain/action/garrison_kernel_action.dart';
import '../../../domain/game/game.dart';
import '../../../domain/map/cell_content_type.dart';
import '../../../domain/map/map_cell.dart';
import '../../../domain/objective/guide/guide_advisor.dart';
import '../../../domain/volcano/kernel_garrison.dart';
import '../../extensions/action_failure_extensions.dart';
import '../../extensions/cell_content_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../widgets/map/effects/map_effects.dart';
import '../../widgets/map/effects/strike/map_strike.dart';
import '../../widgets/map/volcanic_kernel_sheet.dart';
import '../../widgets/unit/unit_picker_dialog.dart';
import 'fight/kernel_army_selection_screen.dart';
import 'fight/kernel_fight_summary_screen.dart';
import 'game_screen_assault_plan.dart';
import 'game_screen_faction_actions.dart';

/// Opens the sheet of the volcanic kernel at ([x], [y]) on [level]: the
/// plan of an assault on it, its garrison once [isCaptured], or the
/// attack on it while a rival holds it. An assault plays on the map
/// through [effects].
void openVolcanicKernelSheet(
  BuildContext context,
  Game game,
  GameRepository repository,
  int x,
  int y,
  int level, {
  required bool isCaptured,
  required VoidCallback onChanged,
  MapEffects? effects,
}) {
  if (isKernelHeldByRival(game, game.levels[level]!.cellAt(x, y))) {
    openRivalKernelSheet(context, game, repository, x, y, onChanged,
        effects: effects);
    return;
  }
  showVolcanicKernelSheet(
    context,
    isCaptured: isCaptured,
    player: game.humanPlayer,
    level: level,
    assaultPlan: isCaptured ? null : assaultPlanAt(game, level, x, y),
    garrisonGuided: isGarrisonGuided(game),
    onAttack: () => handleAttackVolcanicKernel(
        context, game, repository, x, y, level, onChanged,
        effects: effects),
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

/// Lets the player choose an army and assault the volcano the kraken
/// guards at ([x], [y]); the assault then plays on the map through
/// [effects], before its report.
Future<void> handleAttackVolcanicKernel(
  BuildContext context,
  Game game,
  GameRepository repository,
  int x,
  int y,
  int level,
  VoidCallback onChanged, {
  MapEffects? effects,
}) async {
  final navigator = Navigator.of(context);
  final result = await navigator.push<AttackVolcanicKernelResult>(
    MaterialPageRoute(
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
  if (result == null) return;
  await effects?.strike(MapStrike.onVolcano(target: (x, y),
      sprite: CellContentType.volcanicKernel.svgPath!, result: result));
  if (!navigator.mounted) return;
  await navigator.push(MaterialPageRoute<void>(
    builder: (_) =>
        KernelFightSummaryScreen(result: result, targetX: x, targetY: y),
  ));
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
