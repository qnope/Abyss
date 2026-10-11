import 'package:flutter/material.dart';
import '../../../domain/turn/turn_result.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../raid/raid_turn_section.dart';
import '../volcano/volcano_turn_section.dart';
import 'attack_turn_section.dart';
import 'event_turn_section.dart';
import 'exploration_summary_section.dart';
import 'objective_turn_section.dart';
import 'resource_change_line.dart';
import 'summary_line.dart';
import 'turn_loss_sections.dart';

Future<void> showTurnSummaryDialog(
  BuildContext context, {
  required TurnResult result,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => _TurnSummaryDialog(result: result),
  );
}

class _TurnSummaryDialog extends StatelessWidget {
  final TurnResult result;

  const _TurnSummaryDialog({required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.turnTransition(result.previousTurn, result.newTurn)),
      content: _buildContent(l10n),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonOk),
        ),
      ],
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    final hasChanges = result.changes.isNotEmpty;
    final hasWarnings = result.deactivatedBuildings.isNotEmpty;
    final hasLosses = result.lostUnits.isNotEmpty;
    final showArmy = result.hadRecruitedUnits;
    final hasExplorations = result.explorations.isNotEmpty;
    final hasRaid = RaidTurnSection.hasContent(result);
    final hasVolcano = VolcanoTurnSection.hasContent(result);
    final hasEvent = EventTurnSection.hasContent(result);
    final hasObjectives = ObjectiveTurnSection.hasContent(result);
    final hasAttacks = AttackTurnSection.hasContent(result);

    if (!hasChanges && !hasWarnings && !hasLosses && !showArmy &&
        !hasExplorations && !hasRaid && !hasVolcano && !hasEvent &&
        !hasObjectives && !hasAttacks) {
      return Text(l10n.turnNoChange);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final change in result.changes)
          ResourceChangeLine(change: change),
        Flexible(
          child: Scrollbar(
            child: SingleChildScrollView(
              child: _buildEvents(
                l10n,
                hasChanges: hasChanges,
                hasWarnings: hasWarnings,
                hasLosses: hasLosses,
                hasExplorations: hasExplorations,
                showArmy: showArmy,
                hasRaid: hasRaid,
                hasVolcano: hasVolcano,
                hasEvent: hasEvent,
                hasObjectives: hasObjectives,
                hasAttacks: hasAttacks,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEvents(
    AppLocalizations l10n, {
    required bool hasChanges,
    required bool hasWarnings,
    required bool hasLosses,
    required bool hasExplorations,
    required bool showArmy,
    required bool hasRaid,
    required bool hasVolcano,
    required bool hasEvent,
    required bool hasObjectives,
    required bool hasAttacks,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasWarnings)
          DeactivatedBuildingsSection(buildings: result.deactivatedBuildings),
        if (hasLosses) LostUnitsSection(units: result.lostUnits),
        if (hasExplorations)
          ExplorationSummarySection(explorations: result.explorations),
        if (hasRaid) RaidTurnSection(result: result),
        if (hasAttacks) AttackTurnSection(result: result),
        if (hasVolcano) VolcanoTurnSection(result: result),
        if (hasEvent) EventTurnSection(result: result),
        if (hasObjectives) ObjectiveTurnSection(result: result),
        if (showArmy) ...[
          if (hasChanges || hasWarnings || hasLosses || hasExplorations)
            const Divider(),
          _buildArmySection(l10n),
        ],
      ],
    );
  }

  Widget _buildArmySection(AppLocalizations l10n) => SummaryLine(
      Icons.shield, l10n.turnRecruitAvailable, AbyssColors.success);
}
