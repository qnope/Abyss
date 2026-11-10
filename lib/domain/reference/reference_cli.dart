import 'game_snapshot.dart';
import 'reference_arguments.dart';
import 'reference_exporter.dart';
import 'reference_io.dart';
import 'reference_set.dart';

/// What `bin/export_reference.dart` does, away from the real files so a
/// test can run it. [run] returns the exit code of the tool.
class ReferenceCli {
  static const String defaultFolder = 'reference/games';

  /// Endings of the files a dump and a trace are written in, beside the
  /// game they come from; they are not games to check.
  static const String dumpSuffix = '.dump.json';
  static const String traceSuffix = '.trace.json';

  final ReferenceIo io;
  final TextDigest digest;

  const ReferenceCli({required this.io, required this.digest});

  int run(List<String> args) {
    final ReferenceArguments options = ReferenceArguments.parse(args);
    if (options.has('check')) return _regenerate(options['check']!, false);
    if (options.has('update')) return _regenerate(options['update']!, true);
    return _export(options);
  }

  ReferenceExporter get _exporter =>
      ReferenceExporter(digest: digest, read: io.read);

  /// Plays every reference of [folder] again. With [update] the files
  /// that changed are written back; without, they are written in a
  /// temporary folder to compare, and named, and the tool fails.
  int _regenerate(String folder, bool update) {
    final String from = folder.isEmpty ? defaultFolder : folder;
    final Map<String, String> committed = <String, String>{
      for (final String name in io.list(from))
        if (!name.endsWith(dumpSuffix) && !name.endsWith(traceSuffix))
          name: io.read('$from/$name'),
    };
    final Map<String, String> regenerated = ReferenceSet(
      _exporter,
    ).regenerateAll(committed);
    final List<String> stale = ReferenceSet.stale(committed, regenerated);
    if (stale.isEmpty) {
      io.log('${committed.length} reference games up to date in $from');
      return 0;
    }
    final String into = update ? from : io.temporaryFolder();
    for (final String name in stale) {
      io.write('$into/$name', regenerated[name]!);
      io.log('${update ? 'updated' : 'differs'}: $from/$name');
    }
    if (update) return 0;
    io.log(
      '${stale.length} of ${committed.length} reference games differ; '
      'regenerated in $into. Run with --update once the change of the '
      'rules is meant.',
    );
    return 1;
  }

  int _export(ReferenceArguments options) {
    final String? out = options['out'];
    final String? dumpTurn = options['dump-turn'];
    final int? traceTurn = options.number('trace-turn');
    final ReferenceExport export = _exporter.export(
      options.source(io.read),
      traceTurn: traceTurn,
      dumpTurn: dumpTurn == null ? null : int.tryParse(dumpTurn) ?? dumpTurn,
    );
    // Beside the game's file, or the reference it was read from.
    final String base = (out ?? options['reference'] ?? 'reference.json')
        .replaceFirst(RegExp(r'\.json$'), '');
    _write(out, export.game.text);
    _write(
      export.dump == null ? null : '$base.turn-$dumpTurn$dumpSuffix',
      export.dump,
    );
    _write(
      export.trace == null ? null : '$base.turn-$traceTurn$traceSuffix',
      export.trace,
    );
    io.log(
      '${export.game.status.name} at turn ${export.game.turn}, '
      '${export.game.turns.length} turns digested',
    );
    return 0;
  }

  void _write(String? path, String? text) {
    if (path == null || text == null) return;
    io.write(path, text);
    io.log('wrote $path (${text.length} characters)');
  }
}
