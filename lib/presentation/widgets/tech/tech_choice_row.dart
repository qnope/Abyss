import 'package:flutter/material.dart';
import '../../../domain/tech/tech_branch.dart';
import '../../../domain/tech/tech_option.dart';
import '../../extensions/tech_branch_extensions.dart';
import '../../extensions/tech_node_extensions.dart';
import '../../l10n/l10n_extension.dart';
import 'tech_option_card.dart';

/// The two exclusive options of a choice node, face to face.
class TechChoiceRow extends StatelessWidget {
  final TechBranch branch;
  final int level;

  /// Option already taken, `null` while the node is not researched.
  final TechOption? taken;

  /// Takes an option; `null` while the node cannot be researched.
  final ValueChanged<TechOption>? onChoose;

  const TechChoiceRow({
    super.key,
    required this.branch,
    required this.level,
    this.taken,
    this.onChoose,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _card(context, TechOption.a)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Center(child: Text(context.l10n.techScreenOr)),
          ),
          Expanded(child: _card(context, TechOption.b)),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, TechOption option) {
    final status = taken == null
        ? TechOptionStatus.open
        : taken == option
            ? TechOptionStatus.taken
            : TechOptionStatus.discarded;
    final l10n = context.l10n;
    return TechOptionCard(
      iconPath: branch.nodeIconPath(level, option),
      name: branch.nodeName(l10n, level, option),
      effect: branch.nodeEffect(l10n, level, option),
      color: branch.color,
      status: status,
      onChoose: onChoose == null ? null : () => onChoose!(option),
    );
  }
}
