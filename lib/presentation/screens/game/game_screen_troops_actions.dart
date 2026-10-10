import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/game/game.dart';
import '../../../domain/map/captured_base_finder.dart';
import '../../widgets/volcano/kernel_garrison_panel.dart';
import '../../extensions/transition_base_name_extensions.dart';
import '../../l10n/l10n_extension.dart';
import 'game_screen_kernel_actions.dart';
import 'game_screen_transition_actions.dart';

/// Section of a building sheet that sends troops without the map: the
/// descent through the base a Module or a Capsule serves, and the
/// kernel's garrison. `null` when [building] moves no troops yet.
Widget? troopsSectionFor(
  BuildContext context,
  Game game,
  GameRepository repository,
  Building building,
  VoidCallback onChanged,
) {
  if (building.level <= 0) return null;
  final human = game.humanPlayer;
  switch (building.type) {
    case BuildingType.descentModule:
    case BuildingType.pressureCapsule:
      final level = building.type == BuildingType.descentModule ? 1 : 2;
      final captured = CapturedBaseFinder.on(game, level, human.id);
      if (captured == null) return null;
      return FilledButton.icon(
        icon: const Icon(Icons.arrow_downward),
        label: Text(context.l10n.screenDescendThrough(
          captured.base.displayName(context.l10n),
        )),
        onPressed: () {
          Navigator.pop(context);
          handleDescend(
            context, game, repository, captured.base,
            captured.position.x, captured.position.y, level,
            onChanged: onChanged, onLevelSelected: (_) {},
          );
        },
      );
    case BuildingType.volcanicKernel:
      if (!game.isVolcanicKernelCapturedBy(human.id)) return null;
      return KernelGarrisonPanel(
        player: human,
        onGarrison: () {
          Navigator.pop(context);
          handleGarrisonKernel(context, game, repository, onChanged);
        },
        onWithdraw: () {
          Navigator.pop(context);
          handleGarrisonKernel(
            context, game, repository, onChanged, withdraw: true);
        },
      );
    default:
      return null;
  }
}
