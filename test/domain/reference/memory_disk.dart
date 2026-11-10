import 'package:abyss/domain/reference/reference_cli.dart';
import 'package:abyss/domain/reference/reference_io.dart';

import '../../../tool/reference/sha256_hex.dart';

/// Files kept in memory, and what the tool said.
class MemoryDisk {
  final Map<String, String> files = <String, String>{};
  final List<String> log = <String>[];

  ReferenceCli get cli => ReferenceCli(
    digest: sha256Hex,
    io: ReferenceIo(
      read: (path) => files[path] ?? (throw StateError('no file $path')),
      write: (path, text) => files[path] = text,
      list:
          (folder) => [
            for (final String path in files.keys.toList()..sort())
              if (path.startsWith('$folder/') && path.endsWith('.json'))
                path.substring(folder.length + 1),
          ],
      temporaryFolder: () => '/tmp/regenerated',
      log: log.add,
    ),
  );

  int run(List<String> args) => cli.run(args);
}
