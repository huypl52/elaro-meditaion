import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elaro_mobile/main.dart';
import 'package:elaro_mobile/runtime/session.dart';

void main() {
  testWidgets('Home has quick emotion chips and can pass check-in to session start', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('checkin-calm')), findsOneWidget);
    expect(find.byKey(const Key('checkin-low')), findsOneWidget);
    expect(find.byKey(const Key('checkin-overload')), findsOneWidget);

    await tester.tap(find.byKey(const Key('checkin-low')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-body-cta-0')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('session-start-button')));
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pumpAndSettle();

    expect(find.text('manual_checkin: low'), findsOneWidget);
    expect(find.text('noise_context_label: manual-low'), findsNothing);
  });

  testWidgets('Skipping quick check-in still starts the session with null manual checkin', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-body-cta-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('session-start-button')));
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pumpAndSettle();

    expect(find.text('manual_checkin: null'), findsOneWidget);
  });

  test('Runtime uses manual noise context labels when no microphone or low-confidence', () {
    final noMic = SessionTimerState.fromStartEvent(
      {'manual_checkin': 'overload'},
      hasMicrophone: false,
    );

    expect(noMic.noiseContextLabel, 'manual-overload');

    final lowConfidence = SessionTimerState.fromStartEvent(
      {'manual_checkin': 'low'},
      hasMicrophone: true,
      noiseConfidence: 0.2,
    );

    expect(lowConfidence.noiseContextLabel, 'manual-low');
  });
}
