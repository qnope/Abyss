import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/game/game.dart';
import '../../../domain/objective/objective_migration.dart';
import '../../../domain/objective/objective_state.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../tip/tip_guide.dart';
import 'labeled_switch.dart';

/// The guide and tip switches of the human player of [game], each change
/// saved with the game through [repository] right away, and the way to
/// the Guide of the tips already seen.
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
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LabeledSwitch(
          title: l10n.tutorialGuideSwitch,
          subtitle: l10n.tutorialGuideSwitchHint,
          value: _state.tutorialEnabled,
          onChanged: (on) => _change((state) => state.tutorialEnabled = on),
        ),
        LabeledSwitch(
          title: l10n.tutorialTipsSwitch,
          subtitle: l10n.tutorialTipsSwitchHint,
          value: _state.tipsEnabled,
          onChanged: (on) => _change((state) => state.tipsEnabled = on),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.menu_book, color: AbyssColors.biolumCyan),
          title: Text(l10n.tutorialReviewTips),
          onTap: () => showTipGuide(context, _state),
        ),
      ],
    );
  }
}
