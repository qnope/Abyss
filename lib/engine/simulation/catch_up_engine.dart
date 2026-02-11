import 'package:abysses/domain/models/resource.dart';

class CatchUpReport {
  final Map<int, Resources> resourceGains;
  final List<String> buildingsCompleted;
  final List<String> researchCompleted;
  final List<String> offlineEvents;
  final Duration offlineDuration;

  CatchUpReport({
    this.resourceGains = const {},
    this.buildingsCompleted = const [],
    this.researchCompleted = const [],
    this.offlineEvents = const [],
    this.offlineDuration = Duration.zero,
  });

  bool get isEmpty =>
      resourceGains.isEmpty &&
      buildingsCompleted.isEmpty &&
      researchCompleted.isEmpty &&
      offlineEvents.isEmpty;
}

class CatchUpEngine {
  CatchUpReport processOfflineTime({
    required DateTime lastSaved,
    required DateTime now,
  }) {
    final delta = now.difference(lastSaved);
    if (delta.inSeconds < 60) {
      return CatchUpReport(offlineDuration: delta);
    }

    // Placeholder: actual implementation will iterate over colonies and calculate
    // linear production, completed buildings/research, and random events
    return CatchUpReport(
      offlineDuration: delta,
      resourceGains: {},
      buildingsCompleted: [],
      researchCompleted: [],
      offlineEvents: [],
    );
  }
}
