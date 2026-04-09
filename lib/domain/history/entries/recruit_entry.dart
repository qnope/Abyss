part of '../history_entry.dart';

/// History entry recording the recruitment of a batch of units.
@HiveType(typeId: 21)
class RecruitEntry extends HistoryEntry {
  @HiveField(0)
  @override
  final int turn;

  @HiveField(1)
  @override
  final HistoryEntryCategory category;

  @HiveField(2)
  @override
  final String title;

  @HiveField(3)
  @override
  final String? subtitle;

  @HiveField(4)
  final UnitType unitType;

  @HiveField(5)
  final int quantity;

  RecruitEntry({
    required this.turn,
    required this.unitType,
    required this.quantity,
    this.subtitle,
  }) : category = HistoryEntryCategory.recruit,
       title = '$quantity ${_unitLabel(unitType, quantity)} recrutés';
}

String _unitLabel(UnitType type, int quantity) {
  final plural = quantity > 1;
  return switch (type) {
    UnitType.scout => plural ? 'éclaireurs' : 'éclaireur',
    UnitType.harpoonist => plural ? 'harponneurs' : 'harponneur',
    UnitType.guardian => plural ? 'gardiens' : 'gardien',
    UnitType.domeBreaker => plural ? 'briseurs' : 'briseur',
    UnitType.siphoner => plural ? 'siphonneurs' : 'siphonneur',
    UnitType.saboteur => plural ? 'saboteurs' : 'saboteur',
  };
}
