import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/action/action_executor.dart';
import '../../../domain/action/garrison_kernel_action.dart';
import '../../../domain/game/game.dart';
import '../../../domain/volcano/kernel_garrison.dart';
import '../../extensions/action_failure_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../widgets/unit/unit_picker_dialog.dart';
import 'fight/kernel_army_selection_screen.dart';

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
  final picked = await showUnitPickerDialog(
    context,
    title: withdraw ? 'Retirer de la garnison' : 'Mettre en garnison',
    availableUnits: player.unitsOnLevel(
      withdraw ? KernelGarrison.stockKey : KernelGarrison.volcanoLevel,
    ),
    confirmLabel: withdraw ? 'Retirer' : 'Envoyer',
    info: withdraw
        ? 'Les unités retirées rejoignent le niveau 3.'
        : 'Seule la garnison défend le Noyau contre les vagues du Kraken.',
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
        ? 'Garnison : ${KernelGarrison.sizeOf(player)} unités'
        : result.failureMessage(context.l10n)),
  ));
  onChanged();
}
