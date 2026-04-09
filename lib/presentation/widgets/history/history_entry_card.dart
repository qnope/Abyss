import 'package:flutter/material.dart';
import '../../../domain/history/history_entry.dart';
import '../../extensions/history_entry_category_extensions.dart';
import '../../extensions/history_entry_extensions.dart';

/// Renders a single [HistoryEntry] as a colored [Card] with an icon,
/// title, optional subtitle and turn number.
///
/// Combat entries are tappable (trailing chevron + [InkWell] wrapping)
/// since they can be replayed from their stored [FightResult]. Every
/// other category renders as a static card showing `Tour N` on the
/// trailing side.
///
/// All visual data (icon, accent color, tappability) comes from the
/// presentation extensions in `history_entry_category_extensions.dart`
/// and `history_entry_extensions.dart`; this widget keeps no switch of
/// its own on entry subtypes.
class HistoryEntryCard extends StatelessWidget {
  const HistoryEntryCard({
    super.key,
    required this.entry,
    this.onTap,
  });

  final HistoryEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = entry.accentColor(theme);
    final tappable = entry.isTappable;

    final subtitleText = _buildSubtitle(tappable: tappable);
    final listTile = ListTile(
      leading: Icon(entry.category.icon, color: accent),
      title: Text(entry.title),
      subtitle: subtitleText == null ? null : Text(subtitleText),
      trailing: tappable
          ? const Icon(Icons.chevron_right)
          : Text('Tour ${entry.turn}'),
      onTap: tappable ? onTap : null,
    );

    return Card(
      color: accent.withValues(alpha: 0.15),
      child: listTile,
    );
  }

  /// Combat cards prepend `Tour N` to their subtitle so the trailing
  /// chevron has room; static cards keep the raw subtitle (if any) and
  /// let the trailing slot display the turn on its own.
  String? _buildSubtitle({required bool tappable}) {
    if (!tappable) return entry.subtitle;
    final base = 'Tour ${entry.turn}';
    final extra = entry.subtitle;
    if (extra == null || extra.isEmpty) return base;
    return '$base \u00B7 $extra';
  }
}
