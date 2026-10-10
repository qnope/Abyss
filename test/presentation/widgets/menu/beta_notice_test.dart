import 'package:abyss/presentation/app_version.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/menu/beta_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tells the beta version in one discreet line', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AbyssTheme.create(),
        home: const Scaffold(body: BetaNotice()),
      ),
    );
    expect(
      find.textContaining(
        'Version bêta $appVersion · les sauvegardes peuvent être effacées',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });
}
