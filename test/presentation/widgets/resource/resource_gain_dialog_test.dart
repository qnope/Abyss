import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/resource/resource_gain_dialog.dart';
import '../../../helpers/test_svg_helper.dart';

Widget _app({
  required String title,
  required Map<ResourceType, int> deltas,
  String? emptyMessage,
}) {
  return MaterialApp(
    theme: AbyssTheme.create(),
    home: Scaffold(
      body: Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () => showResourceGainDialog(
            ctx,
            title: title,
            deltas: deltas,
            emptyMessage: emptyMessage ?? 'Rien a recuperer ici...',
          ),
          child: const Text('Open'),
        ),
      ),
    ),
  );
}

Future<void> _open(WidgetTester t) async {
  await t.tap(find.text('Open'));
  await t.pumpAndSettle();
}

void main() {
  group('ResourceGainDialog', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    testWidgets('renders one line per non-zero resource', (t) async {
      await t.pumpWidget(_app(
        title: 'Gains',
        deltas: const {
          ResourceType.algae: 75,
          ResourceType.coral: 0,
          ResourceType.ore: 12,
        },
      ));
      await _open(t);

      expect(find.text('+75'), findsOneWidget);
      expect(find.text('+12'), findsOneWidget);
      expect(find.text('+0'), findsNothing);
      expect(find.text('Algues'), findsOneWidget);
      expect(find.text('Minerai'), findsOneWidget);
      expect(find.text('Corail'), findsNothing);
    });

    testWidgets('empty deltas show empty message', (t) async {
      await t.pumpWidget(_app(
        title: 'Gains',
        deltas: const {
          ResourceType.algae: 0,
          ResourceType.coral: 0,
        },
        emptyMessage: 'Coffre vide !',
      ));
      await _open(t);

      expect(find.text('Coffre vide !'), findsOneWidget);
      expect(find.textContaining('+'), findsNothing);
    });

    testWidgets('completely empty map shows empty message', (t) async {
      await t.pumpWidget(_app(
        title: 'Gains',
        deltas: const {},
        emptyMessage: 'Rien trouve',
      ));
      await _open(t);

      expect(find.text('Rien trouve'), findsOneWidget);
    });

    testWidgets('OK button closes the dialog', (t) async {
      await t.pumpWidget(_app(
        title: 'Gains',
        deltas: const {ResourceType.algae: 5},
      ));
      await _open(t);

      expect(find.byType(AlertDialog), findsOneWidget);
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('title is rendered', (t) async {
      await t.pumpWidget(_app(
        title: 'Tresor collecte !',
        deltas: const {ResourceType.algae: 5},
      ));
      await _open(t);

      expect(find.text('Tresor collecte !'), findsOneWidget);
    });

    testWidgets('order is canonical (algae before pearl)', (t) async {
      await t.pumpWidget(_app(
        title: 'Gains',
        deltas: const {
          ResourceType.pearl: 1,
          ResourceType.algae: 1,
        },
      ));
      await _open(t);

      final algaeY = t.getTopLeft(find.text('Algues')).dy;
      final pearlY = t.getTopLeft(find.text('Perles')).dy;
      expect(algaeY, lessThan(pearlY));
    });
  });
}
