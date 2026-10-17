import 'package:flutter/material.dart';

import '../common/lore_text.dart';

/// Header of a section of the objectives sheet: its [title], then the
/// [lore] line of its chapter when it has one.
class ObjectiveSectionHeader extends StatelessWidget {
  final String title;
  final String? lore;

  const ObjectiveSectionHeader({super.key, required this.title, this.lore});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleSmall),
          if (lore != null) ...[
            const SizedBox(height: 2),
            LoreText(lore!, style: textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
