import 'package:flutter/material.dart';

import '../../../domain/faction/faction.dart';
import '../../extensions/faction_personality_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/faction_colors.dart';
import '../common/lore_text.dart';
import 'faction_emblem.dart';

/// Who a faction is, centred: its emblem, its name in its colour, and
/// where it comes from in a line of lore.
class FactionIdentity extends StatelessWidget {
  final Faction faction;

  const FactionIdentity({super.key, required this.faction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FactionEmblem(personality: faction.personality, size: 64),
        const SizedBox(height: 12),
        Text(
          faction.name,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: FactionColors.of(faction.personality),
          ),
        ),
        const SizedBox(height: 8),
        LoreText(
          faction.personality.origin(context.l10n),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
