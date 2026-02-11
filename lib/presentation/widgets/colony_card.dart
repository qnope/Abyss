import 'package:flutter/material.dart';

class ColonyCard extends StatelessWidget {
  final String name;
  final String archetype;
  final int disposition;
  final double distance;

  const ColonyCard({
    super.key,
    required this.name,
    required this.archetype,
    required this.disposition,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _dispositionColor,
          child: Text(name[0], style: const TextStyle(color: Colors.white)),
        ),
        title: Text(name),
        subtitle: Text('$archetype · ${distance.toStringAsFixed(0)} km'),
        trailing: Text(
          _dispositionLabel,
          style: TextStyle(color: _dispositionColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Color get _dispositionColor {
    if (disposition > 50) return const Color(0xFF66BB6A);
    if (disposition > 0) return const Color(0xFF42A5F5);
    if (disposition > -50) return const Color(0xFFFF7043);
    return const Color(0xFFE53935);
  }

  String get _dispositionLabel {
    if (disposition > 75) return 'Allié';
    if (disposition > 20) return 'Amical';
    if (disposition > -20) return 'Neutre';
    if (disposition > -50) return 'Hostile';
    return 'Ennemi';
  }
}
