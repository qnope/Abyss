import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResearchScreen extends ConsumerWidget {
  const ResearchScreen({super.key});

  static const _branches = [
    ('Architecture', Icons.architecture),
    ('Armement', Icons.gps_fixed),
    ('Sciences', Icons.biotech),
    ('Énergie', Icons.bolt),
    ('Central', Icons.explore),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: _branches.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recherche'),
          bottom: TabBar(
            isScrollable: true,
            tabs: _branches
                .map((b) => Tab(icon: Icon(b.$2), text: b.$1))
                .toList(),
          ),
        ),
        body: TabBarView(
          children: _branches.map((b) => _buildBranchView(b.$1)).toList(),
        ),
      ),
    );
  }

  Widget _buildBranchView(String branchName) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTechTile('Tier 1', 'Disponible', false),
        _buildTechTile('Tier 2', 'Verrouillé', true),
        _buildTechTile('Tier 3', 'Verrouillé', true),
      ],
    );
  }

  Widget _buildTechTile(String tier, String status, bool locked) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          locked ? Icons.lock : Icons.lock_open,
          color: locked ? Colors.grey : const Color(0xFF66BB6A),
        ),
        title: Text(tier),
        subtitle: Text(status),
        trailing: locked
            ? null
            : ElevatedButton(
                onPressed: () {},
                child: const Text('Rechercher'),
              ),
      ),
    );
  }
}
