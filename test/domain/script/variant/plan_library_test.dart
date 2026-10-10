import 'package:abyss/domain/script/script_library.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('offers each human plan with its variants', () {
    final Set<String> names = ScriptLibrary.names.toSet();

    for (final String plan in <String>['plan85', 'plan84']) {
      expect(names, contains(plan));
      expect(names, contains('$plan-newmap'));
      expect(names, contains('$plan-slow'));
    }
  });

  test('plays the plan84 replay on its own map', () {
    expect(ScriptLibrary.byName('plan84').mapSeed, 2083200441);
  });
}
