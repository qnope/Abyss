import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  static const _categories = [
    ('Critique', Color(0xFFE53935)),
    ('Alliés', Color(0xFF42A5F5)),
    ('Ennemis', Color(0xFFFF7043)),
    ('Commerce', Color(0xFF66BB6A)),
    ('Diplo', Color(0xFFAB47BC)),
    ('Monde', Color(0xFF78909C)),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: _categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          bottom: TabBar(
            isScrollable: true,
            tabs: _categories
                .map((c) => Tab(
                      child: Text(c.$1, style: TextStyle(color: c.$2)),
                    ))
                .toList(),
          ),
        ),
        body: TabBarView(
          children: _categories
              .map((c) => Center(
                    child: Text(
                      'Aucun message ${c.$1.toLowerCase()}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
