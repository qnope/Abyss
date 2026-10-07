import 'package:abyss/presentation/widgets/warm_up/warm_up_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget layer(Future<void> Function() load) => MaterialApp(
        builder: (context, child) => WarmUpLayer(
          load: load,
          pages: [(_) => const Text('page A'), (_) => const Text('page B')],
          child: child!,
        ),
        home: const Text('screen'),
      );

  testWidgets('paints each page once after loading, then removes them', (
    tester,
  ) async {
    await tester.pumpWidget(layer(() async {}));
    expect(find.text('screen'), findsOneWidget);
    expect(find.text('page A'), findsNothing);

    await tester.pump();
    expect(find.text('page A'), findsOneWidget);
    await tester.pump();
    expect(find.text('page A'), findsNothing);
    expect(find.text('page B'), findsOneWidget);
    await tester.pump();
    expect(find.text('page B'), findsNothing);
    expect(find.text('screen'), findsOneWidget);
  });

  testWidgets('shows no page when loading fails', (tester) async {
    await tester.pumpWidget(layer(() async => throw StateError('no art')));
    await tester.pump();
    await tester.pump();
    expect(find.text('page A'), findsNothing);
    expect(find.text('screen'), findsOneWidget);
  });

  testWidgets('pages never receive taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => WarmUpLayer(
        load: () async {},
        pages: [
          (_) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => taps++,
                child: const SizedBox(width: 800, height: 600),
              ),
        ],
        child: child!,
      ),
      home: const SizedBox.shrink(),
    ));
    await tester.pump();
    await tester.tapAt(const Offset(10, 10));
    expect(taps, 0);
  });
}
