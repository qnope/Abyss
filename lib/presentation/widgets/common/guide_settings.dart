import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/game/game.dart';
import '../../../domain/objective/objective_migration.dart';
import '../../../domain/objective/objective_state.dart';
import 'labeled_switch.dart';

/// The guide and tip switches of the human player of [game]; each change
/// is saved with the game through [repository] right away.
class GuideSettings extends StatefulWidget {
  const GuideSettings({
    super.key,
    required this.game,
    required this.repository,
  });

  final Game game;
  final GameRepository repository;

  @override
  State<GuideSettings> createState() => _GuideSettingsState();
}

class _GuideSettingsState extends State<GuideSettings> {
  ObjectiveState get _state =>
      ObjectiveMigration.stateOf(widget.game, widget.game.humanPlayer);

  Future<void> _change(void Function(ObjectiveState state) apply) async {
    setState(() => apply(_state));
    await widget.repository.save(widget.game);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LabeledSwitch(
          title: 'Guide du tutoriel',
          subtitle: 'Le guide te montre quoi faire, objectif après objectif',
          value: _state.tutorialEnabled,
          onChanged: (on) => _change((state) => state.tutorialEnabled = on),
        ),
        LabeledSwitch(
          title: 'Conseils',
          subtitle: 'Une fiche présente chaque écran la première fois',
          value: _state.tipsEnabled,
          onChanged: (on) => _change((state) => state.tipsEnabled = on),
        ),
      ],
    );
  }
}
