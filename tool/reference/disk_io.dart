import 'dart:io';

import 'package:abyss/domain/reference/reference_io.dart';

/// The files of the disk, for `bin/export_reference.dart`; [log] gets
/// what the tool says, the standard output by default.
ReferenceIo diskIo({void Function(String line)? log}) => ReferenceIo(
  read: (String path) => File(path).readAsStringSync(),
  write:
      (String path, String text) =>
          File(path)
            ..parent.createSync(recursive: true)
            ..writeAsStringSync(text),
  list:
      (String folder) => <String>[
        for (final FileSystemEntity f in Directory(folder).listSync())
          if (f is File && f.path.endsWith('.json')) f.uri.pathSegments.last,
      ]..sort(),
  temporaryFolder:
      () => Directory.systemTemp.createTempSync('abyss-reference-').path,
  log: log ?? stdout.writeln,
);
