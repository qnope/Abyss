part of '../history_entry.dart';

/// History entry recording the capture of a transition base, or of the
/// volcanic kernel.
///
/// Carries the full [FightResult] so the combat can be replayed from the
/// history view, same pattern as [CombatEntry].
@HiveType(typeId: 34)
class CaptureEntry extends HistoryEntry {
  @HiveField(0)
  @override
  final int turn;

  @HiveField(1)
  @override
  final HistoryEntryCategory category;

  /// Left empty: the presentation titles the entry in the player's
  /// language. Kept so the Hive layout keeps its field 2.
  @HiveField(2)
  final String title;

  /// Not shown: a French line some older versions saved.
  @HiveField(3)
  final String? subtitle;

  @HiveField(4)
  final String transitionBaseName;

  @HiveField(5)
  final FightResult fightResult;

  /// The [transitionBaseName] of the capture of the volcanic kernel.
  static const String volcanicKernel = 'volcanicKernel';

  CaptureEntry({
    required this.turn,
    required this.transitionBaseName,
    required this.fightResult,
    this.subtitle,
  }) : category = HistoryEntryCategory.capture,
       title = '';

  /// The [transitionBaseName] older saves stored for the kernel capture.
  static const String legacyVolcanicKernel = 'Noyau Volcanique';

  /// Whether the volcanic kernel was captured rather than a transition
  /// base.
  bool get isVolcanicKernel =>
      transitionBaseName == volcanicKernel ||
      transitionBaseName == legacyVolcanicKernel;
}
