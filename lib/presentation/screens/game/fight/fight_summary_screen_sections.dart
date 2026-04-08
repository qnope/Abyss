import 'package:flutter/material.dart';
import '../../../../domain/action/fight_monster_result.dart';
import '../../../../domain/resource/resource_type.dart';
import '../../../../domain/unit/unit_type.dart';
import '../../../extensions/resource_type_extensions.dart';
import '../../../theme/abyss_colors.dart';
import '../../../widgets/resource/resource_icon.dart';
import '../../../widgets/unit/unit_icon.dart';

Widget _card(Widget child) =>
    Card(child: Padding(padding: const EdgeInsets.all(16), child: child));

Widget buildResultBanner(BuildContext context, FightMonsterResult result) {
  final textTheme = Theme.of(context).textTheme;
  final isVictory = result.victory;
  final color = isVictory ? AbyssColors.biolumCyan : AbyssColors.warning;
  return _card(Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        isVictory ? 'VICTOIRE' : 'DÉFAITE',
        style: textTheme.headlineMedium
            ?.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text(
        'Combat en ${result.fight!.turnCount} tours',
        style: textTheme.bodyMedium?.copyWith(color: AbyssColors.onSurfaceDim),
      ),
    ],
  ));
}

Widget buildPlayerAccounting(
    BuildContext context, FightMonsterResult result) {
  final textTheme = Theme.of(context).textTheme;
  return _card(Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Vos unités',
        style: textTheme.titleMedium?.copyWith(color: AbyssColors.biolumCyan),
      ),
      const SizedBox(height: 8),
      for (final t in result.sent.keys) _unitRow(context, t, result),
    ],
  ));
}

Widget _unitRow(
    BuildContext context, UnitType type, FightMonsterResult result) {
  final textTheme = Theme.of(context).textTheme;
  final sent = result.sent[type] ?? 0;
  final intact = result.survivorsIntact[type] ?? 0;
  final wounded = result.wounded[type] ?? 0;
  final dead = result.dead[type] ?? 0;
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      UnitIcon(type: type, size: 28),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          'Envoyés: $sent / Intactes: $intact '
          '/ Blessés: $wounded / Morts: $dead',
          style: textTheme.bodyMedium?.copyWith(color: AbyssColors.onSurface),
        ),
      ),
    ]),
  );
}

Widget buildMonsterSection(
    BuildContext context, FightMonsterResult result) {
  final textTheme = Theme.of(context).textTheme;
  final initial = result.fight!.initialMonsterCount;
  final killed = initial - result.fight!.finalMonsterCount;
  return _card(Text(
    'Ennemis tués: $killed/$initial',
    style: textTheme.bodyMedium?.copyWith(color: AbyssColors.onSurface),
  ));
}

Widget buildLoot(BuildContext context, FightMonsterResult result) {
  final textTheme = Theme.of(context).textTheme;
  final entries = result.loot.entries.where((e) => e.value != 0).toList();
  return _card(Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Butin',
        style: textTheme.titleMedium?.copyWith(color: AbyssColors.biolumCyan),
      ),
      const SizedBox(height: 8),
      if (entries.isEmpty)
        Text(
          'Aucun butin',
          style:
              textTheme.bodyMedium?.copyWith(color: AbyssColors.onSurfaceDim),
        )
      else
        for (final e in entries) _lootRow(context, e.key, e.value),
    ],
  ));
}

Widget _lootRow(BuildContext context, ResourceType type, int amount) {
  final textTheme = Theme.of(context).textTheme;
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      ResourceIcon(type: type, size: 20),
      const SizedBox(width: 8),
      Text(
        '${type.displayName} +$amount',
        style: textTheme.bodyMedium?.copyWith(color: AbyssColors.onSurface),
      ),
    ]),
  );
}
