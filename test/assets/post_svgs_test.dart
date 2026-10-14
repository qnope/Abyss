import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The Faille, the Cheminée and the passages below them each have one
/// illustration per holder: still guarded, held by the human, held by a
/// faction.
void main() {
  const posts = ['faille', 'cheminee', 'passage_faille', 'passage_cheminee'];
  const holders = ['guarded', 'player', 'faction'];

  for (final post in posts) {
    for (final holder in holders) {
      final path = 'assets/icons/posts/${post}_$holder.svg';
      test('$path exists and stays light', () {
        final file = File(path);
        expect(file.existsSync(), isTrue);
        expect(file.lengthSync(), lessThan(48 * 1024));
      });
    }
  }

  test('pubspec declares the posts folder', () {
    expect(File('pubspec.yaml').readAsStringSync(),
        contains('- assets/icons/posts/'));
  });
}
