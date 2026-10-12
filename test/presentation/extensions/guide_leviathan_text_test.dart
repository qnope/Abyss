import 'package:abyss/domain/objective/guide/guide_message.dart';
import 'package:abyss/presentation/extensions/guide_message_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  const intro =
      'Le Léviathan revient reprendre sa Faille ! Seules tes unités du '
      'niveau 2 la défendent. Si elle tombe, ton Module est détruit et tes '
      "unités d'en bas sont perdues.";

  test('warns of the guardians coming back to the Faille', () {
    expect(const GuideLeviathanReturn(2).text(fr), intro);
  });

  test('adds the Harpoonists to send when some are missing', () {
    expect(
      const GuideLeviathanReturn(2, missing: 6).text(fr),
      '$intro Envoie 6 Harponneurs de plus.',
    );
    expect(
      const GuideLeviathanReturn(2, missing: 1).text(en),
      endsWith('Send 1 more Harpooner.'),
    );
    expect(
      const GuideLeviathanReturn(2, missing: 3).text(es),
      startsWith('¡El Leviatán vuelve'),
    );
  });
}
