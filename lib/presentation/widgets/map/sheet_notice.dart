import 'package:flutter/material.dart';

import '../../theme/abyss_colors.dart';

/// Short timed notice of a map sheet, e.g. « Épave : encore 3 tours ».
class SheetNotice extends StatelessWidget {
  final String text;

  const SheetNotice(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.hourglass_bottom,
            size: 18,
            color: AbyssColors.warning,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AbyssColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}
