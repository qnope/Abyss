import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/resource/resource_bar_item.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  group('ResourceBarItem', () {
    setUp(() => mockSvgAssets());
    tearDown(() => clearSvgMocks());

    Widget createApp(
      Resource resource, {
      VoidCallback? onTap,
      int production = 0,
      int consumption = 0,
    }) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: ResourceBarItem(
            resource: resource,
            production: production,
            consumption: consumption,
            onTap: onTap,
          ),
        ),
      );
    }

    testWidgets('renders amount text', (tester) async {
      final resource = Resource(type: ResourceType.algae, amount: 100);
      await tester.pumpWidget(createApp(resource));
      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('shows production rate when > 0', (tester) async {
      final resource = Resource(type: ResourceType.coral, amount: 80);
      await tester.pumpWidget(createApp(resource, production: 8));
      await tester.pumpAndSettle();
      expect(find.text('+8/t'), findsOneWidget);
    });

    testWidgets('hides production for pearl (rate = 0)', (tester) async {
      final resource = Resource(
        type: ResourceType.pearl, amount: 5, maxStorage: 100,
      );
      await tester.pumpWidget(createApp(resource));
      await tester.pumpAndSettle();
      expect(find.text('5'), findsOneWidget);
      expect(find.textContaining('/t'), findsNothing);
    });

    testWidgets('onTap callback fires', (tester) async {
      var tapped = false;
      final resource = Resource(type: ResourceType.energy, amount: 60);
      await tester.pumpWidget(
        createApp(resource, production: 6, onTap: () => tapped = true),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ResourceBarItem));
      expect(tapped, isTrue);
    });

    group('consumption display', () {
      testWidgets('shows only production when consumption is 0',
          (tester) async {
        final resource = Resource(type: ResourceType.algae, amount: 100);
        await tester.pumpWidget(
          createApp(resource, production: 50, consumption: 0),
        );
        await tester.pumpAndSettle();
        expect(find.text('+50/t'), findsOneWidget);
        expect(find.textContaining('-'), findsNothing);
      });

      testWidgets('shows production and consumption', (tester) async {
        final resource = Resource(type: ResourceType.algae, amount: 100);
        await tester.pumpWidget(
          createApp(resource, production: 50, consumption: 12),
        );
        await tester.pumpAndSettle();
        expect(find.text('+50/-12/t'), findsOneWidget);
      });

      testWidgets('uses alert color when consumption exceeds production',
          (tester) async {
        final resource = Resource(type: ResourceType.algae, amount: 100);
        await tester.pumpWidget(
          createApp(resource, production: 10, consumption: 20),
        );
        await tester.pumpAndSettle();
        final text = tester.widget<Text>(find.text('+10/-20/t'));
        expect(text.style?.color, AbyssColors.error);
      });

      testWidgets('uses normal color when production covers consumption',
          (tester) async {
        final resource = Resource(type: ResourceType.algae, amount: 100);
        await tester.pumpWidget(
          createApp(resource, production: 50, consumption: 10),
        );
        await tester.pumpAndSettle();
        final text = tester.widget<Text>(find.text('+50/-10/t'));
        expect(text.style?.color, isNot(AbyssColors.error));
      });

      testWidgets('hides production line when both are 0', (tester) async {
        final resource = Resource(type: ResourceType.algae, amount: 100);
        await tester.pumpWidget(
          createApp(resource, production: 0, consumption: 0),
        );
        await tester.pumpAndSettle();
        expect(find.textContaining('/t'), findsNothing);
      });
    });
  });
}
