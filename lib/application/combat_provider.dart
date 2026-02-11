import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:abysses/domain/models/combat_report.dart';

class CombatNotifier extends StateNotifier<CombatReport?> {
  CombatNotifier() : super(null);

  void setCombatReport(CombatReport report) {
    state = report;
  }

  void clearReport() {
    state = null;
  }
}

final combatProvider =
    StateNotifierProvider<CombatNotifier, CombatReport?>((ref) {
  return CombatNotifier();
});

final combatHistoryProvider =
    StateNotifierProvider<CombatHistoryNotifier, List<CombatReport>>((ref) {
  return CombatHistoryNotifier();
});

class CombatHistoryNotifier extends StateNotifier<List<CombatReport>> {
  CombatHistoryNotifier() : super([]);

  void addReport(CombatReport report) {
    state = [report, ...state];
  }
}
