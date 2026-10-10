// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_entry_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryEntryCategoryAdapter extends TypeAdapter<HistoryEntryCategory> {
  @override
  final typeId = 18;

  @override
  HistoryEntryCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HistoryEntryCategory.combat;
      case 1:
        return HistoryEntryCategory.building;
      case 2:
        return HistoryEntryCategory.research;
      case 3:
        return HistoryEntryCategory.recruit;
      case 4:
        return HistoryEntryCategory.explore;
      case 5:
        return HistoryEntryCategory.collect;
      case 6:
        return HistoryEntryCategory.turnEnd;
      case 7:
        return HistoryEntryCategory.capture;
      case 8:
        return HistoryEntryCategory.descent;
      case 9:
        return HistoryEntryCategory.reinforcement;
      case 10:
        return HistoryEntryCategory.raid;
      case 11:
        return HistoryEntryCategory.volcano;
      case 12:
        return HistoryEntryCategory.event;
      default:
        return HistoryEntryCategory.combat;
    }
  }

  @override
  void write(BinaryWriter writer, HistoryEntryCategory obj) {
    switch (obj) {
      case HistoryEntryCategory.combat:
        writer.writeByte(0);
      case HistoryEntryCategory.building:
        writer.writeByte(1);
      case HistoryEntryCategory.research:
        writer.writeByte(2);
      case HistoryEntryCategory.recruit:
        writer.writeByte(3);
      case HistoryEntryCategory.explore:
        writer.writeByte(4);
      case HistoryEntryCategory.collect:
        writer.writeByte(5);
      case HistoryEntryCategory.turnEnd:
        writer.writeByte(6);
      case HistoryEntryCategory.capture:
        writer.writeByte(7);
      case HistoryEntryCategory.descent:
        writer.writeByte(8);
      case HistoryEntryCategory.reinforcement:
        writer.writeByte(9);
      case HistoryEntryCategory.raid:
        writer.writeByte(10);
      case HistoryEntryCategory.volcano:
        writer.writeByte(11);
      case HistoryEntryCategory.event:
        writer.writeByte(12);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryEntryCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
