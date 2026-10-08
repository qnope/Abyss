import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce/src/binary/binary_reader_impl.dart';
import 'package:hive_ce/src/binary/binary_writer_impl.dart';

import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';
import 'package:abyss/domain/tech/tech_option.dart';
import 'package:abyss/domain/tech/tech_perk.dart';

const _boxName = 'tech_branch_state_hive_test';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_tech_hive_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(TechBranchAdapter());
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(TechBranchStateAdapter());
    }
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(_boxName);
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('a saved branch keeps the options it chose', () async {
    final box = await Hive.openBox<TechBranchState>(_boxName);
    await box.put(
      'military',
      TechBranchState(
        branch: TechBranch.military,
        unlocked: true,
        researchLevel: 4,
      )
        ..choose(2, TechOption.b)
        ..choose(4, TechOption.a),
    );
    await box.close();

    final reopened = await Hive.openBox<TechBranchState>(_boxName);
    final loaded = reopened.get('military')!;

    expect(loaded.researchLevel, 4);
    expect(loaded.choices, [TechOption.b.index, TechOption.a.index]);
    expect(loaded.optionAt(2), TechOption.b);
    expect(loaded.optionAt(4), TechOption.a);
    expect(loaded.perks, {TechPerk.nacreShell, TechPerk.livingRampart});
  });

  test('a save older than the choices loads with option A everywhere', () {
    // Only fields 0..2, as the adapter wrote them before step 9.
    final writer = BinaryWriterImpl(Hive)
      ..writeByte(3)
      ..writeByte(0)
      ..write(TechBranch.explorer)
      ..writeByte(1)
      ..write(true)
      ..writeByte(2)
      ..write(5);

    final decoded = TechBranchStateAdapter()
        .read(BinaryReaderImpl(writer.toBytes(), Hive));

    expect(decoded.branch, TechBranch.explorer);
    expect(decoded.researchLevel, 5);
    expect(decoded.choices, isEmpty);
    expect(decoded.optionAt(2), TechOption.a);
    expect(decoded.optionAt(4), TechOption.a);
    expect(decoded.perks, {TechPerk.deepSonar, TechPerk.wreckRaiders});
    // The decoded list must accept a later choice.
    decoded.choose(2, TechOption.b);
    expect(decoded.optionAt(2), TechOption.b);
  });
}
