import 'package:hive_ce/hive.dart';
// Hive keeps its own adapters (dates, big integers, durations) apart from
// its public API; resetting the adapters clears them along with the app's.
// ignore_for_file: implementation_imports
import 'package:hive_ce/src/adapters/big_int_adapter.dart';
import 'package:hive_ce/src/adapters/date_time_adapter.dart';
import 'package:hive_ce/src/adapters/duration_adapter.dart';

/// Puts Hive back as at startup: no box open, and none of the app's
/// adapters registered, so a test may register them again; Hive's own
/// adapters stay, as Hive registers them when created.
Future<void> resetHive() async {
  await Hive.close();
  Hive
    ..resetAdapters()
    ..registerAdapter(DateTimeWithTimezoneAdapter(), internal: true)
    ..registerAdapter(DateTimeAdapter<DateTimeWithoutTZ>(), internal: true)
    ..registerAdapter(BigIntAdapter(), internal: true)
    ..registerAdapter(DurationAdapter(), internal: true);
}
