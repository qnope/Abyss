import '../../history/history_entry.dart';
import '../class_snapshot.dart';

/// Builds the snapshot of one class of history entries: its turn, its
/// category and its [own] fields.
abstract final class HistoryEntrySnapshot {
  /// Why `title` and `subtitle` are left out of every entry that has them.
  static const Map<String, String> legacyTexts = <String, String>{
    'title':
        'always empty: the presentation words the entry; the field '
        'only keeps the layout of old Hive saves',
    'subtitle':
        'never set by the rules (always null in a game started '
        'today): a French line some older versions saved',
  };

  static ClassSnapshot<T> of<T extends HistoryEntry>(
    String className,
    Map<String, FieldWriter<T>> own, {
    Map<String, String> omitted = legacyTexts,
  }) => ClassSnapshot<T>(className, <String, FieldWriter<T>>{
    'turn': (e, _) => e.turn,
    'category': (e, _) => e.category.name,
    ...own,
  }, omitted: omitted);
}
