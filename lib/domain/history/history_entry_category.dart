import 'package:hive/hive.dart';

part 'history_entry_category.g.dart';

@HiveType(typeId: 18)
enum HistoryEntryCategory {
  @HiveField(0) combat,
  @HiveField(1) building,
  @HiveField(2) research,
  @HiveField(3) recruit,
  @HiveField(4) explore,
  @HiveField(5) collect,
  @HiveField(6) turnEnd,
}
