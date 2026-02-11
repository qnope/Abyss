import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FleetScreen extends ConsumerWidget {
  const FleetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flotte')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Torpilleurs'),
          _buildUnitTile('Raie', 'T1', 0, Icons.speed),
          _buildUnitTile('Espadon', 'T2', 0, Icons.speed),
          _buildUnitTile('Fantôme', 'T3', 0, Icons.speed),
          const SizedBox(height: 16),
          _buildSectionHeader('Essaims'),
          _buildUnitTile('Alevin', 'T1', 0, Icons.pest_control),
          _buildUnitTile('Piranha', 'T2', 0, Icons.pest_control),
          _buildUnitTile('Méduse', 'T3', 0, Icons.pest_control),
          const SizedBox(height: 16),
          _buildSectionHeader('Léviathans'),
          _buildUnitTile('Nautile', 'T1', 0, Icons.shield),
          _buildUnitTile('Kraken', 'T2', 0, Icons.shield),
          _buildUnitTile('Béhémoth', 'T3', 0, Icons.shield),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.send),
        label: const Text('Déployer'),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF64B5F6)),
      ),
    );
  }

  Widget _buildUnitTile(String name, String tier, int count, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF64B5F6)),
        title: Text(name),
        subtitle: Text(tier),
        trailing: Text('×$count', style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
