import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/player.dart';

void main() {
  group('Player', () {
    test('creates player with name', () {
      final player = Player(name: 'Nemo');

      expect(player.name, 'Nemo');
    });
  });
}
