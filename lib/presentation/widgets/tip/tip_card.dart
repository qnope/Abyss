import 'package:flutter/material.dart';

import '../../../domain/objective/tip/tip.dart';
import '../../extensions/tip_id_extensions.dart';
import '../../extensions/tip_texts.dart';
import '../../l10n/l10n_extension.dart';
import '../common/illustrated_card.dart';

/// Opens the card of [tip]; completes once it is closed.
Future<void> showTipCard(BuildContext context, Tip tip) =>
    showDialog<void>(context: context, builder: (_) => TipCard(tip: tip));

/// Dialog of a « première fois » tip: its illustration, its title, its
/// lines and a button to close it.
class TipCard extends StatelessWidget {
  final Tip tip;

  const TipCard({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    final text = tip.id.text(context.l10n);
    return IllustratedCard(
      illustration: tip.id.illustration,
      title: text.title,
      lines: text.lines,
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.commonGotIt),
        ),
      ],
    );
  }
}
