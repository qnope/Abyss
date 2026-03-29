import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/resource.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/resource_bar_item.dart';
import '../../helpers/test_svg_helper.dart';

void main() {
  group('ResourceBarItem', () {
    setUp(() => mockSvgAssets());
    tearDown(() => clearSvgMocks());

    Widget createApp(Resource resource, {VoidCallback? onTap}) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: ResourceBarItem(resource: resource, onTap: onTap),
        ),
      );
    }

    testWidgets('renders amount text', (tester) async {
      final resource = Resource(
        type: ResourceType.algae,
        amount: 100,
        productionPerTurn: 10,
      );
      await tester.pumpWidget(createApp(resource));
      await tester.pumpAndSettle();

      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('shows production rate when > 0', (tester) async {
      final resource = Resource(
        type: ResourceType.coral,
        amount: 80,
        productionPerTurn: 8,
      );
      await tester.pumpWidget(createApp(resource));
      await tester.pumpAndSettle();

      expect(find.text('+8/t'), findsOneWidget);
    });

    testWidgets('hides production for pearl (rate = 0)', (tester) async {
      final resource = Resource(
        type: ResourceType.pearl,
        amount: 5,
        productionPerTurn: 0,
      );
      await tester.pumpWidget(createApp(resource));
      await tester.pumpAndSettle();

      expect(find.text('5'), findsOneWidget);
      expect(find.textContaining('/t'), findsNothing);
    });

    testWidgets('onTap callback fires', (tester) async {
      var tapped = false;
      final resource = Resource(
        type: ResourceType.energy,
        amount: 60,
        productionPerTurn: 6,
      );
      await tester.pumpWidget(
        createApp(resource, onTap: () => tapped = true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ResourceBarItem));
      expect(tapped, isTrue);
    });
  });
}
