import 'package:flutter/material.dart';

import '../../theme/abyss_colors.dart';

/// Card of a fight report: [child] with the report's padding.
class FightReportCard extends StatelessWidget {
  final Widget child;

  const FightReportCard({super.key, required this.child});

  /// A card holding a single line of [text], e.g. the enemies killed.
  factory FightReportCard.line(String text, {Key? key}) =>
      FightReportCard(key: key, child: _ReportLine(text));

  @override
  Widget build(BuildContext context) =>
      Card(child: Padding(padding: const EdgeInsets.all(16), child: child));
}

class _ReportLine extends StatelessWidget {
  final String text;

  const _ReportLine(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: AbyssColors.onSurface),
  );
}
