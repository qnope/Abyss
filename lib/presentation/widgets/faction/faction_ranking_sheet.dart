import 'package:flutter/material.dart';

import '../../../domain/faction/faction_standing.dart';
import '../../../domain/game/game.dart';
import '../../l10n/l10n_extension.dart';
import '../common/sheet_drag_handle.dart';
import 'faction_standing_tile.dart';

/// Opens the modal bottom sheet ranking the human and the factions of
/// [game].
Future<void> showFactionRankingSheet(BuildContext context, Game game) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => FactionRankingSheetBody(
      standings: FactionStanding.ranking(game),
    ),
  );
}

/// Body of the ranking sheet: one [FactionStandingTile] per [standings].
class FactionRankingSheetBody extends StatelessWidget {
  final List<FactionStanding> standings;

  const FactionRankingSheetBody({super.key, required this.standings});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            const SheetDragHandle(),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                context.l10n.factionRankingTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                children: [
                  for (final s in standings) FactionStandingTile(standing: s),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
