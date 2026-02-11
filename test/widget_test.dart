import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:abysses/presentation/app.dart';

void main() {
  testWidgets('App renders with bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AbyssesApp()),
    );

    expect(find.text('Base'), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Flotte'), findsOneWidget);
    expect(find.text('Carte'), findsOneWidget);
    expect(find.text('Recherche'), findsOneWidget);
  });
}
