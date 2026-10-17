import 'package:abyss/presentation/widgets/common/lore_text.dart';
import 'package:abyss/presentation/widgets/objective/objective_section_header.dart';
import 'package:flutter_test/flutter_test.dart';

import 'objective_widget_helpers.dart';

void main() {
  testWidgets('shows the lore line under the title', (tester) async {
    await tester.pumpWidget(
      objectiveApp(
        const ObjectiveSectionHeader(
          title: '2. Le récif',
          lore: 'Le récif écoute.',
        ),
      ),
    );

    final title = find.text('2. Le récif');
    final lore = find.text('Le récif écoute.');
    expect(title, findsOneWidget);
    expect(
      find.ancestor(of: lore, matching: find.byType(LoreText)),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(lore).dy,
      greaterThan(tester.getTopLeft(title).dy),
    );
  });

  testWidgets('shows the title alone without lore', (tester) async {
    await tester.pumpWidget(
      objectiveApp(const ObjectiveSectionHeader(title: 'Événements')),
    );

    expect(find.text('Événements'), findsOneWidget);
    expect(find.byType(LoreText), findsNothing);
  });
}
