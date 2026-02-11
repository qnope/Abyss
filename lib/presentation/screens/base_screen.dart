import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/resource_bar.dart';

class BaseScreen extends ConsumerWidget {
  const BaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('ABYSSES - Base')),
      body: Column(
        children: [
          const ResourceBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader('Bâtiments'),
                _buildBuildingTile('Ferme biomasse', 'Niv. 1', '100/h', Icons.grass),
                _buildBuildingTile('Mine minéraux', 'Niv. 1', '80/h', Icons.diamond),
                _buildBuildingTile('Centrale énergie', 'Niv. 1', '120/h', Icons.bolt),
                _buildBuildingTile('Comptoir commercial', 'Niv. 1', '60/h', Icons.store),
                const SizedBox(height: 16),
                _buildSectionHeader('Militaire'),
                _buildBuildingTile('Chantier naval', 'Niv. 1', '', Icons.build),
                _buildBuildingTile('Baie de lancement', 'Niv. 1', '', Icons.rocket_launch),
                const SizedBox(height: 16),
                _buildSectionHeader('Utilitaire'),
                _buildBuildingTile('Habitat', 'Niv. 1', 'Pop: 50', Icons.home),
                _buildBuildingTile('Laboratoire', 'Niv. 1', '', Icons.biotech),
                _buildBuildingTile('Entrepôt', 'Niv. 1', '', Icons.warehouse),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
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

  Widget _buildBuildingTile(String name, String level, String production, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF64B5F6)),
        title: Text(name),
        subtitle: Text(level),
        trailing: production.isNotEmpty
            ? Text(production, style: const TextStyle(color: Color(0xFF81C784)))
            : null,
      ),
    );
  }
}
