import 'package:hive/hive.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/history/history_entry_category.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/unit/unit_type.dart';

part 'entries/building_entry.dart';
part 'entries/collect_entry.dart';
part 'entries/explore_entry.dart';
part 'entries/recruit_entry.dart';
part 'entries/research_entry.dart';
part 'history_entry.g.dart';

/// Abstract base class for all history entries.
///
/// Each player action and end-of-turn event produces a concrete subclass
/// of [HistoryEntry]. The sealed hierarchy enables exhaustive `switch` on
/// concrete types in the presentation layer.
///
/// Because `HistoryEntry` is a sealed class, all direct subclasses must
/// live in this same library and are declared via `part` files under
/// `entries/`. Each concrete subclass defines its own `@HiveType` and
/// `@HiveField` annotations (Hive does not walk abstract bases).
sealed class HistoryEntry {
  const HistoryEntry();

  int get turn;
  HistoryEntryCategory get category;
  String get title;
  String? get subtitle;
}
