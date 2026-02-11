import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:abysses/domain/models/colony.dart';

class ColonyListNotifier extends StateNotifier<List<Colony>> {
  ColonyListNotifier() : super([]);

  void setColonies(List<Colony> colonies) {
    state = colonies;
  }

  void addColony(Colony colony) {
    state = [...state, colony];
  }

  void updateColony(Colony updated) {
    state = [
      for (final c in state)
        if (c.id == updated.id) updated else c,
    ];
  }

  void removeColony(int id) {
    state = state.where((c) => c.id != id).toList();
  }
}

final colonyListProvider =
    StateNotifierProvider<ColonyListNotifier, List<Colony>>((ref) {
  return ColonyListNotifier();
});

final playerColonyProvider = Provider<Colony?>((ref) {
  final colonies = ref.watch(colonyListProvider);
  try {
    return colonies.firstWhere((c) => c.ownerType == OwnerType.player);
  } catch (_) {
    return null;
  }
});

final colonyProvider = Provider.family<Colony?, int>((ref, id) {
  final colonies = ref.watch(colonyListProvider);
  try {
    return colonies.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
});
