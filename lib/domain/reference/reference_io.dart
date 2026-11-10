/// The files and the console the export tool works with; `bin/` gives
/// the real ones, a test gives its own.
class ReferenceIo {
  /// The text of the file at a path.
  final String Function(String path) read;

  final void Function(String path, String text) write;

  /// The names of the `.json` files of a folder, sorted.
  final List<String> Function(String folder) list;

  /// Makes a folder for files to compare and returns its path.
  final String Function() temporaryFolder;

  final void Function(String line) log;

  const ReferenceIo({
    required this.read,
    required this.write,
    required this.list,
    required this.temporaryFolder,
    required this.log,
  });
}
