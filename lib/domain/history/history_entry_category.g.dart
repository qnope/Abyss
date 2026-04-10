// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_entry_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryEntryCategoryAdapter extends TypeAdapter<HistoryEntryCategory> {
  @override
  final int typeId = 18;

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
      default:
        return HistoryEntryCategory.combat;
    }
  }

  @override
  void write(BinaryWriter writer, HistoryEntryCategory obj) {
    switch (obj) {
      case HistoryEntryCategory.combat:
        writer.writeByte(0);
        break;
      case HistoryEntryCategory.building:
        writer.writeByte(1);
        break;
      case HistoryEntryCategory.research:
        writer.writeByte(2);
        break;
      case HistoryEntryCategory.recruit:
        writer.writeByte(3);
        break;
      case HistoryEntryCategory.explore:
        writer.writeByte(4);
        break;
      case HistoryEntryCategory.collect:
        writer.writeByte(5);
        break;
      case HistoryEntryCategory.turnEnd:
        writer.writeByte(6);
        break;
      case HistoryEntryCategory.capture:
        writer.writeByte(7);
        break;
      case HistoryEntryCategory.descent:
        writer.writeByte(8);
        break;
      case HistoryEntryCategory.reinforcement:
        writer.writeByte(9);
        break;
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
