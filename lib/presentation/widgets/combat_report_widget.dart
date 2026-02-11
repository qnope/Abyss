import 'package:flutter/material.dart';

import 'package:abysses/domain/models/combat_report.dart';

class CombatReportWidget extends StatelessWidget {
  final CombatReport report;

  const CombatReportWidget({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rapport de combat',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                _buildResultBadge(),
              ],
            ),
            const Divider(),
            Text('Attaquant #${report.attackerId} vs Défenseur #${report.defenderId}'),
            const SizedBox(height: 8),
            Text('Rounds: ${report.rounds}'),
            Text('Type: ${report.combatType.name}'),
            if (report.attackerLosses.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Pertes attaquant: ${_formatLosses(report.attackerLosses)}'),
            ],
            if (report.defenderLosses.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Pertes défenseur: ${_formatLosses(report.defenderLosses)}'),
            ],
            if (report.spoils != null) ...[
              const SizedBox(height: 8),
              Text(
                'Butin: ${report.spoils!.total} ressources',
                style: const TextStyle(color: Color(0xFFFFD54F)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultBadge() {
    final (label, color) = switch (report.result) {
      CombatResult.attackerVictory => ('Victoire ATK', Color(0xFF66BB6A)),
      CombatResult.defenderVictory => ('Victoire DEF', Color(0xFFE53935)),
      CombatResult.draw => ('Match nul', Color(0xFFFF7043)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  String _formatLosses(Map<String, int> losses) {
    return losses.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }
}
