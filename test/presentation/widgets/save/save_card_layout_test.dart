import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/save_card_harness.dart';
import '../../../helpers/save_summary_helpers.dart';

void main() {
  testWidgets('ellipsizes a long name and fits 320 px', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final name = 'Capitaine ' * 8;

    await tester.pumpWidget(
      saveCardApp(
        summaryOf(
          playerName: name,
          difficulty: Difficulty.hard,
          lastPlayedAt: DateTime(2025, 1, 12),
          resources: {for (final t in ResourceType.values) t: 123456},
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final text = tester.widget<Text>(find.text(name));
    expect(text.overflow, TextOverflow.ellipsis);
    expect(text.maxLines, 1);
    expect(find.text('12 janv. 2025'), findsOneWidget);
  });
}
