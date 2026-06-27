import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elaro_mobile/main.dart';
import 'package:elaro_mobile/domain/timeline.dart';
import 'package:elaro_mobile/features/session/session.dart';
import 'package:elaro_mobile/runtime/session.dart';

void main() {
  setUp(() {
    const SessionRuntime().resetForTests();
  });

  Future<void> _openSessionStart(WidgetTester tester) async {
    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(
      '/session/start',
      arguments: const SessionStartArgs(
        sessionRoute: '/session/short-breath',
        manualCheckin: CheckinState.low,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('SessionStartScreen shows micro duration chips', (WidgetTester tester) async {
    await _openSessionStart(tester);

    expect(find.text('Chọn micro session'), findsOneWidget);
    expect(find.byKey(const Key('micro-20s')), findsOneWidget);
    expect(find.byKey(const Key('micro-45s')), findsOneWidget);
    expect(find.byKey(const Key('micro-90s')), findsOneWidget);
    expect(find.byKey(const Key('micro-3m')), findsOneWidget);
    expect(find.text('20s'), findsOneWidget);
    expect(find.text('45s'), findsOneWidget);
    expect(find.text('90s'), findsOneWidget);
    expect(find.text('3m'), findsOneWidget);
  });

  testWidgets('Micro sessions derive micro fast startup and navigate after 250ms', (
    WidgetTester tester,
  ) async {
    await _openSessionStart(tester);
    await tester.tap(find.byKey(const Key('micro-90s')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('session-start-button')));
    await tester.pump();

    expect(find.byKey(const Key('session-start-loading')), findsOneWidget);
    expect(find.text('Đang khởi động nhanh (micro fast)'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 249));
    expect(find.byKey(const Key('session-start-loading')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('session-start-loading')), findsNothing);
    expect(find.text('manual_checkin: low'), findsOneWidget);
  });

  testWidgets('Non-micro selection derives standard startup and navigates after 1100ms', (
    WidgetTester tester,
  ) async {
    await _openSessionStart(tester);
    await tester.tap(find.byKey(const Key('micro-3m')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('session-start-button')));
    await tester.pump();

    expect(find.byKey(const Key('session-start-loading')), findsOneWidget);
    expect(find.text('Đang khởi động nhanh (standard)'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1099));
    expect(find.byKey(const Key('session-start-loading')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('session-start-loading')), findsNothing);
    expect(find.text('manual_checkin: low'), findsOneWidget);
  });

  test('SessionRuntime.startSession records a session start timeline event', () {
    const runtime = SessionRuntime();
    runtime.resetForTests();

    runtime.startSession(
      sessionRoute: '/session/short-breath',
      manualCheckin: CheckinState.low,
      sessionDurationSeconds: 20,
      startupMode: 'micro fast',
    );

    final startEvents = runtime.timeline
        .where((SessionTimelineEvent event) => event.type == SessionTimelineEventType.sessionStart);
    expect(startEvents, isNotEmpty);

    final startEvent = startEvents.first;
    expect(startEvent.payload[sessionDurationTimelineKey], 20);
    expect(startEvent.payload[startupModeTimelineKey], 'micro fast');
    expect(startEvent.payload['session_route'], '/session/short-breath');
  });
}
