import 'package:abyss/presentation/extensions/decimal_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  test('writes a decimal the way each language does', () {
    expect(1.5.decimal(fr), '1,5');
    expect(1.5.decimal(en), '1.5');
    expect(1.5.decimal(es), '1,5');
  });

  test('keeps one digit after the separator by default', () {
    expect(2.decimal(en), '2.0');
    expect(1.25.decimal(fr, digits: 2), '1,25');
  });
}
