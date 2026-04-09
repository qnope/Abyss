import 'package:flutter/material.dart';

import '../../../domain/history/history_entry.dart';
import 'history_entry_card.dart';
import 'history_fight_launcher.dart';
import 'history_filter.dart';
import 'history_filter_chips.dart';

/// Body of the history modal bottom sheet.
///
/// Stateful because it owns the currently selected [HistoryFilter]. The
/// widget is intentionally public so tests can pump it directly without
/// having to trigger a modal sheet route.
class HistorySheetBody extends StatefulWidget {
  const HistorySheetBody({super.key, required this.entries});

  final List<HistoryEntry> entries;

  @override
  State<HistorySheetBody> createState() => _HistorySheetBodyState();
}

class _HistorySheetBodyState extends State<HistorySheetBody> {
  HistoryFilter _filter = HistoryFilter.all;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: size.height * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDragHandle(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: HistoryFilterChips(
                current: _filter,
                onChanged: (f) => setState(() => _filter = f),
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (widget.entries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Aucune action enregistrée pour l\'instant.'),
        ),
      );
    }

    final reversed = widget.entries.reversed.toList();
    final filtered = applyHistoryFilter(reversed, _filter);

    if (filtered.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Aucune action pour ce filtre.'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];
        return HistoryEntryCard(
          entry: entry,
          onTap: entry is CombatEntry
              ? () => openFightSummaryFromEntry(context, entry)
              : null,
        );
      },
    );
  }
}
