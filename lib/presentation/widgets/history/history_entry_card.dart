import 'package:flutter/material.dart';
import '../../../domain/history/history_entry.dart';
import '../../extensions/history_entry_category_extensions.dart';
import '../../extensions/history_entry_extensions.dart';
import '../../extensions/history_entry_texts.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extension.dart';
import '../common/raster_svg.dart';

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

    final l10n = context.l10n;
    final subtitleText = _buildSubtitle(l10n, tappable: tappable);
    final listTile = ListTile(
      leading: _leading(accent),
      title: Text(entry.displayTitle(l10n)),
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

  /// The entry's illustration when it has one, else its category icon.
  Widget _leading(Color accent) {
    final art = entry.illustration;
    if (art == null) return Icon(entry.category.icon, color: accent);
    return RasterSvg(assetPath: art, size: illustrationSize);
  }

  /// Side of the illustration of an event entry.
  static const double illustrationSize = 40;

  /// Combat cards prepend `Tour N` to their subtitle so the trailing
  /// chevron has room; static cards keep their subtitle (if any) and
  /// let the trailing slot display the turn on its own.
  String? _buildSubtitle(AppLocalizations l10n, {required bool tappable}) {
    final extra = entry.displaySubtitle(l10n);
    if (!tappable) return extra;
    final base = 'Tour ${entry.turn}';
    if (extra == null || extra.isEmpty) return base;
    return '$base \u00B7 $extra';
  }
}
