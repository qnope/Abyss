import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/presentation/widgets/map/volcanic_kernel_sheet.dart';

void main() {
  Widget buildOpener({
    required bool isCaptured,
    VoidCallback? onAttack,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showVolcanicKernelSheet(
              context,
              isCaptured: isCaptured,
              onAttack: onAttack ?? () {},
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  group('VolcanicKernelSheet', () {
    testWidgets('shows title', (tester) async {
      await tester.pumpWidget(buildOpener(isCaptured: false));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Noyau Volcanique'), findsOneWidget);
    });

    testWidgets('when not captured shows attack button', (tester) async {
      await tester.pumpWidget(buildOpener(isCaptured: false));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text("Lancer l'assaut"), findsOneWidget);
    });

    testWidgets('when captured does NOT show attack button', (tester) async {
      await tester.pumpWidget(buildOpener(isCaptured: true));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text("Lancer l'assaut"), findsNothing);
    });

    testWidgets('attack button calls onAttack', (tester) async {
      var called = false;
      await tester.pumpWidget(
        buildOpener(isCaptured: false, onAttack: () => called = true),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Lancer l'assaut"));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('when not captured shows uncaptured description',
        (tester) async {
      await tester.pumpWidget(buildOpener(isCaptured: false));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        find.text('Le coeur brulant des abysses est garde '
            'par de puissants gardiens.'),
        findsOneWidget,
      );
    });

    testWidgets('when captured shows captured description', (tester) async {
      await tester.pumpWidget(buildOpener(isCaptured: true));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Vous avez capture le Noyau Volcanique'),
        findsOneWidget,
      );
    });
  });
}
