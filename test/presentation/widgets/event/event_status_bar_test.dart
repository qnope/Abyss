import 'package:abyss/domain/event/event_state.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/event/event_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> show(
    WidgetTester tester,
    EventState state, {
    VoidCallback? onOpen,
  }) => tester.pumpWidget(MaterialApp(
    theme: AbyssTheme.create(),
    home: Scaffold(
      body: EventStatusBar(state: state, currentTurn: 10, onOpen: onOpen),
    ),
  ));

  testWidgets('is hidden when nothing happens', (tester) async {
    await show(tester, EventState());
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('a pending choice reopens the card when tapped', (
    tester,
  ) async {
    var opened = 0;
    await show(
      tester,
      EventState()..setPending(RandomEventType.survivors, 10),
      onOpen: () => opened++,
    );
    await tester.tap(find.text('Événement : Survivants — choisir'));
    expect(opened, 1);
  });

  testWidgets('counts down a warm current', (tester) async {
    await show(
      tester,
      EventState()..activate(RandomEventType.warmCurrent, untilTurn: 11),
    );
    expect(find.text('Courant chaud : encore 2 tours'), findsOneWidget);
  });

  testWidgets('tells a heated cold current apart', (tester) async {
    await show(
      tester,
      EventState()
        ..activate(RandomEventType.coldCurrent, untilTurn: 12)
        ..heating = true,
    );
    expect(
      find.text('Courant froid (serres chauffées) : encore 3 tours'),
      findsOneWidget,
    );
  });

  testWidgets('counts down a storm on its last turn', (tester) async {
    await show(
      tester,
      EventState()..activate(RandomEventType.storm, untilTurn: 10),
    );
    expect(find.text('Tempête : encore 1 tour'), findsOneWidget);
  });

  testWidgets('forgets an effect that is over', (tester) async {
    await show(
      tester,
      EventState()..activate(RandomEventType.storm, untilTurn: 9),
    );
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('counts down the wreck left on the map', (tester) async {
    await show(
      tester,
      EventState(
        wreckPosition: GridPosition(x: 1, y: 1),
        wreckUntilTurn: 13,
      ),
    );
    expect(find.text('Épave : encore 4 tours'), findsOneWidget);
  });
}
