import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elaro_mobile/main.dart';
import 'package:elaro_mobile/features/session/session.dart';
import 'package:elaro_mobile/runtime/session.dart';
import 'package:elaro_mobile/domain/timeline.dart';

void main() {
  setUp(() {
    const SessionRuntime().resetForTests();
  });

  Future<void> _openCompletedSession(WidgetTester tester) async {
    const runtime = SessionRuntime();
    final startEvent = runtime.startSession(
      sessionRoute: '/session/short-breath',
      manualCheckin: CheckinState.low,
      sessionDurationSeconds: 0,
      startupMode: 'test',
    );
    final timerState = SessionTimerState.fromStartEvent(
      startEvent.toJson(),
      hasMicrophone: true,
    );

    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(
      '/session/active',
      arguments: SessionActiveArgs(
        startEvent: startEvent,
        timerState: timerState,
      ),
    );
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();
  }

  testWidgets('Session re-entry card renders exact copy and 3 CTAs with nudge slot', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    await _openCompletedSession(tester);

    expect(find.text('Kết thúc nhẹ nhàng'), findsOneWidget);
    expect(find.text('Re-entry sau phiên'), findsOneWidget);
    expect(
      find.text('Lời nhắc nhẹ: thở chậm 1 nhịp rồi chọn bước kế tiếp.'),
      findsOneWidget,
    );

    expect(find.byKey(const Key('session-reentry-stop')), findsOneWidget);
    expect(find.byKey(const Key('session-reentry-repeat')), findsOneWidget);
    expect(find.byKey(const Key('session-reentry-followup')), findsOneWidget);

    expect(find.byKey(const Key('session-active-mindful-nudge-card')), findsOneWidget);
    expect(find.byKey(const Key('session-active-mindful-nudge-skip')), findsOneWidget);

    final reentryTop = tester.getTopLeft(find.byKey(const Key('session-reentry-card'))).dy;
    final nudgeTop = tester.getTopLeft(
      find.byKey(const Key('session-active-mindful-nudge-card')),
    ).dy;
    expect(nudgeTop, greaterThan(reentryTop));
  });

  testWidgets('Re-entry stop returns Home and does not add a manual-exit event', (
    WidgetTester tester,
  ) async {
    const runtime = SessionRuntime();
    await _openCompletedSession(tester);

    await tester.ensureVisible(find.byKey(const Key('session-reentry-stop')));
    await tester.tap(find.byKey(const Key('session-reentry-stop')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('checkin-calm')), findsOneWidget);
    expect(
      runtime.timeline.where((SessionTimelineEvent event) => event.type == SessionTimelineEventType.sessionManualExit),
      isEmpty,
    );
  });

  testWidgets('Re-entry repeat opens fresh session start route', (WidgetTester tester) async {
    await _openCompletedSession(tester);

    await tester.ensureVisible(find.byKey(const Key('session-reentry-repeat')));
    await tester.tap(find.byKey(const Key('session-reentry-repeat')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('session-start-button')), findsOneWidget);
    expect(find.text('Phiên: /session/short-breath'), findsOneWidget);
  });

  testWidgets('Re-entry follow-up opens reflection route for the completed session', (
    WidgetTester tester,
  ) async {
    const runtime = SessionRuntime();
    await _openCompletedSession(tester);

    final startEvents = runtime.timeline.where(
      (SessionTimelineEvent event) => event.type == SessionTimelineEventType.sessionStart,
    );
    expect(startEvents, isNotEmpty);
    final sessionId = startEvents.last.payload[sessionIdTimelineKey] as String;

    await tester.ensureVisible(find.byKey(const Key('session-reentry-followup')));
    await tester.tap(find.byKey(const Key('session-reentry-followup')));
    await tester.pumpAndSettle();

    expect(find.text('Phiên ID: $sessionId'), findsOneWidget);
  });

  testWidgets('Re-entry route supports direct deep-link with session id', (WidgetTester tester) async {
    const runtime = SessionRuntime();
    runtime.resetForTests();

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.2)),
        child: const ElaroMedApp(),
      ),
    );
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(
      '/session/manual-session/re-entry',
      arguments: const SessionReEntryArgs(
        sessionId: 'manual-session',
        sessionRoute: '/session/short-breath',
        manualCheckin: CheckinState.low,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Re-entry sau phiên'), findsOneWidget);
    expect(find.byKey(const Key('session-reentry-stop')), findsOneWidget);
  });
}
