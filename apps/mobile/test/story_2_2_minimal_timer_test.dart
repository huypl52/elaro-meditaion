import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elaro_mobile/components/breathing/breathing.dart';
import 'package:elaro_mobile/main.dart';
import 'package:elaro_mobile/domain/timeline.dart';
import 'package:elaro_mobile/features/session/session.dart';
import 'package:elaro_mobile/runtime/dev_gate.dart';
import 'package:elaro_mobile/runtime/session.dart';

void main() {
  setUp(() {
    const runtime = SessionRuntime();
    runtime.resetForTests();
  });

  Future<void> _openActiveSession(WidgetTester tester, {int durationSeconds = 20}) async {
    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(
      '/session/start',
      arguments: SessionStartArgs(
        sessionRoute: '/session/short-breath',
        manualCheckin: CheckinState.low,
        sessionDurationSeconds: durationSeconds,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('session-start-button')));
    await tester.pump();
    expect(find.byKey(const Key('session-start-loading')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 251));
    await tester.pumpAndSettle();
  }

  testWidgets('Session player shows calm UI elements and state label', (WidgetTester tester) async {
    await _openActiveSession(tester, durationSeconds: 45);

    expect(find.byType(SoftTimer), findsOneWidget);
    expect(find.byType(ProgressRing), findsOneWidget);
    expect(find.byType(BreathingCircle), findsOneWidget);
    expect(find.byType(SessionStateLabel), findsOneWidget);
    expect(find.textContaining('Cùng nhau thở.'), findsOneWidget);
    expect(find.byKey(const Key('session-pause-btn')), findsOneWidget);
    expect(find.byKey(const Key('session-return-home')), findsOneWidget);
  });

  test('Bell cue presets resolve by duration band', () {
    expect(resolveBellCues(20), const <int>[5, 10, 15]);
    expect(resolveBellCues(45), const <int>[5, 15, 35]);
    expect(resolveBellCues(90), const <int>[15, 45, 75]);
    expect(resolveBellCues(180), const <int>[45, 90, 135, 175]);
  });

  testWidgets('Pause and resume controls update labels and runtime timeline', (
    WidgetTester tester,
  ) async {
    const runtime = SessionRuntime();
    await _openActiveSession(tester, durationSeconds: 90);

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('session-pause-btn')));
    await tester.pumpAndSettle();

    expect(find.text('Nghỉ một nhịp.'), findsOneWidget);
    expect(find.byKey(const Key('session-resume-btn')), findsOneWidget);
    expect(
      runtime.timeline.where((SessionTimelineEvent e) => e.type == SessionTimelineEventType.sessionPause),
      isNotEmpty,
    );

    await tester.tap(find.byKey(const Key('session-resume-btn')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('session-pause-btn')), findsOneWidget);
    expect(
      runtime.timeline.where((SessionTimelineEvent e) => e.type == SessionTimelineEventType.sessionResume),
      isNotEmpty,
    );
  });

  testWidgets('Manual exit records session-manual-exit timeline event', (WidgetTester tester) async {
    const runtime = SessionRuntime();
    await _openActiveSession(tester, durationSeconds: 20);

    await tester.tap(find.text('Kết thúc sớm'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('checkin-calm')), findsOneWidget);

    final manualExitEvents = runtime.timeline
        .where((SessionTimelineEvent e) => e.type == SessionTimelineEventType.sessionManualExit);
    expect(manualExitEvents, isNotEmpty);
    expect(manualExitEvents.first.payload[reasonTimelineKey], 'manual-exit');
  });

  testWidgets('Resume from interruption shows session-recovery-card', (WidgetTester tester) async {
    const runtime = SessionRuntime();
    await _openActiveSession(tester, durationSeconds: 45);

    final binding = tester.binding;
    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(runtime.hasSessionRecovery(sessionId: runtime.timeline.last.payload[sessionIdTimelineKey] as String), isTrue);

    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('session-recovery-card')), findsOneWidget);
  });

  testWidgets('Session telemetry is hidden in release and wrapped in Session telemetry block in dev', (
    WidgetTester tester,
  ) async {
    await _openActiveSession(tester, durationSeconds: 45);

    if (DevGate.enabled) {
      expect(find.text('Session telemetry'), findsOneWidget);
      expect(find.textContaining('mode:'), findsOneWidget);
      expect(find.textContaining('runtime-event label'), findsOneWidget);
    } else {
      expect(find.text('Session telemetry'), findsNothing);
    }
  });
}
