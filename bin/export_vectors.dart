// Writes the vectors of reference/vectors/: inputs and what the Dart
// rules answer, for the Godot port to answer the same.
//
//   dart run bin/export_vectors.dart            writes reference/vectors/
//   dart run bin/export_vectors.dart --check    exports to a temporary
//       folder and fails, naming them, if files of reference/vectors/
//       differ
//   dart run bin/export_vectors.dart --out <folder>    another folder
//
// See reference/vectors/README.md for the files and their format.
import 'dart:io';

import '../tool/vectors/vector_catalog.dart';
import '../tool/vectors/vector_exporter.dart';

void main(List<String> args) {
  var check = false;
  var folder = VectorCatalog.folder;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--check') {
      check = true;
    } else if (args[i] == '--out' && i + 1 < args.length) {
      folder = args[++i];
    } else {
      stderr.writeln('Usage: export_vectors.dart [--check] [--out <folder>]');
      exit(64);
    }
  }
  final exporter = VectorExporter(VectorCatalog.all);
  if (!check) {
    exporter.writeTo(Directory(folder));
    stdout.writeln('Wrote ${exporter.files.length} vector files to $folder.');
    return;
  }
  final List<String> stale = exporter.staleIn(Directory(folder));
  if (stale.isEmpty) {
    stdout.writeln('The ${exporter.files.length} vector files are up to date.');
    return;
  }
  stderr.writeln('Stale vector files in $folder, run '
      '`dart run bin/export_vectors.dart`:');
  for (final String name in stale) {
    stderr.writeln('  $name');
  }
  exit(1);
}
