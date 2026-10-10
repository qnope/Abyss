import 'package:flutter/material.dart';

import '../../../domain/objective/objective_state.dart';
import '../../../domain/objective/tip/tip.dart';
import '../../../domain/objective/tip/tip_catalog.dart';
import '../../../domain/objective/tip/tip_category.dart';
import '../../extensions/tip_id_extensions.dart';
import '../../theme/abyss_colors.dart';
import '../common/raster_svg.dart';
import 'tip_card.dart';

/// Opens the Guide of the tips [state] has seen.
Future<void> showTipGuide(BuildContext context, ObjectiveState state) =>
    showDialog<void>(
      context: context,
      builder: (_) => TipGuide(state: state),
    );

/// The Guide: every tip, section by section, those seen by their title
/// to open their card again, the others greyed as « ??? ».
class TipGuide extends StatelessWidget {
  final ObjectiveState state;

  const TipGuide({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final label = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: AbyssColors.onSurfaceDim,
    );
    return AlertDialog(
      title: const Text('Guide'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final category in TipCategory.values) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Text(category.label, style: label),
                ),
                for (final tip in TipCatalog.all)
                  if (tip.category == category)
                    _TipTile(tip: tip, seen: state.hasSeen(tip.id)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}

/// One tip of the Guide: its picture and title once [seen], a greyed
/// « ??? » before.
class _TipTile extends StatelessWidget {
  final Tip tip;
  final bool seen;

  const _TipTile({required this.tip, required this.seen});

  static const double _iconSize = 36;

  @override
  Widget build(BuildContext context) {
    if (!seen) {
      return const ListTile(
        enabled: false,
        contentPadding: EdgeInsets.zero,
        leading: SizedBox.square(
          dimension: _iconSize,
          child: Icon(Icons.help_outline, color: AbyssColors.disabled),
        ),
        title: Text('???'),
      );
    }
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: RasterSvg(assetPath: tip.id.illustration, size: _iconSize),
      title: Text(tip.title),
      trailing: const Icon(Icons.chevron_right, color: AbyssColors.onSurfaceDim),
      onTap: () => showTipCard(context, tip),
    );
  }
}
