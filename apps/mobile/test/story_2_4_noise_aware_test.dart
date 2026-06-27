import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elaro_mobile/main.dart';
import 'package:elaro_mobile/domain/timeline.dart';
import 'package:elaro_mobile/features/session/session.dart';
import 'package:elaro_mobile/runtime/session.dart';
import 'package:elaro_mobile/runtime/microphone_permission_runtime.dart';

void main() {
  setUp(() {
    const SessionRuntime().resetForTests();
    MicrophonePermissionRuntime.instance.resetForTests();
  });

  Future<void> _openActiveSession(
    WidgetTester tester, {
    required CheckinState manualCheckin,
    bool simulateNoMicrophone = false,
    bool? preflightHasMicrophone,
    bool simulateLowConfidence = false,
    int durationSeconds = 20,
  }) async {
    if (preflightHasMicrophone != null) {
      MicrophonePermissionRuntime.instance.setPermissionForTests(preflightHasMicrophone);
    }

    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(
      '/session/start',
      arguments: SessionStartArgs(
        sessionRoute: '/session/short-breath',
        manualCheckin: manualCheckin,
        simulateNoMicrophone: simulateNoMicrophone,
        simulateLowConfidence: simulateLowConfidence,
        sessionDurationSeconds: durationSeconds,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('session-start-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pumpAndSettle();
  }

  test('SessionTimerState uses low-confidence cutoff at 0.6 and returns manual context', () {
    final withLowConfidence = SessionTimerState.fromStartEvent(
      {manualCheckinTimelineKey: 'low'},
      hasMicrophone: true,
      noiseConfidence: 0.55,
    );
    final withHighConfidence = SessionTimerState.fromStartEvent(
      {manualCheckinTimelineKey: 'low'},
      hasMicrophone: true,
      noiseConfidence: 0.66,
    );

    expect(withLowConfidence.isLowConfidence, isTrue);
    expect(withLowConfidence.usingManualContext, isTrue);
    expect(withLowConfidence.noiseContextLabel, 'manual-low');

    expect(withHighConfidence.isLowConfidence, isFalse);
    expect(withHighConfidence.usingManualContext, isFalse);
  });

  test('SessionRuntime.dropEnrichment disables mic and forces low-confidence state', () {
    const runtime = SessionRuntime();
    const timerState = SessionTimerState(
      manualContext: CheckinState.calm,
      hasMicrophone: true,
      noiseConfidence: 0.9,
      sessionDurationSeconds: 20,
      elapsedSeconds: 0,
      isPaused: false,
    );

    final dropped = runtime.dropEnrichment(timerState: timerState);

    expect(dropped.hasMicrophone, isFalse);
    expect(dropped.noiseConfidence, 0.2);
    expect(dropped.isLowConfidence, isTrue);
    expect(dropped.noiseContextLabel, 'manual-calm');
  });

  testWidgets('No-mic start shows manual context and low-confidence label without claims', (
    WidgetTester tester,
  ) async {
    await _openActiveSession(
      tester,
      manualCheckin: CheckinState.overload,
      preflightHasMicrophone: false,
      durationSeconds: 20,
    );

    expect(find.text('Context thủ công: manual-overload'), findsOneWidget);
    expect(find.text('độ tin cậy thấp'), findsOneWidget);
    expect(find.textContaining('phát hiện môi trường ồn'), findsNothing);
  });

  testWidgets('Low confidence start shows manual context and low-confidence label', (
    WidgetTester tester,
  ) async {
    await _openActiveSession(
      tester,
      manualCheckin: CheckinState.low,
      simulateLowConfidence: true,
      durationSeconds: 20,
    );

    expect(find.text('Context thủ công: manual-low'), findsOneWidget);
    expect(find.text('độ tin cậy thấp'), findsOneWidget);
  });

  testWidgets('Recovery card appears on interruption and exposes three recovery actions', (
    WidgetTester tester,
  ) async {
    await _openActiveSession(
      tester,
      manualCheckin: CheckinState.calm,
      durationSeconds: 20,
    );

    final binding = tester.binding;
    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('session-recovery-card')), findsOneWidget);
    expect(find.byKey(const Key('session-recovery-resume')), findsOneWidget);
    expect(find.byKey(const Key('session-recovery-close')), findsOneWidget);
    expect(find.byKey(const Key('session-recovery-new')), findsOneWidget);
  });

  testWidgets('Mid-session mic denial from permission runtime drops enrichment, shows bypass copy, and keeps session timeline baseline', (
    WidgetTester tester,
  ) async {
    const runtime = SessionRuntime();
    await _openActiveSession(
      tester,
      manualCheckin: CheckinState.calm,
      durationSeconds: 20,
    );

    final startEvents = runtime.timeline.where((SessionTimelineEvent event) => event.type == SessionTimelineEventType.sessionStart);
    expect(startEvents.length, 1);

    MicrophonePermissionRuntime.instance.setPermissionForTests(false);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Enrichment: bỏ qua (thiếu quyền mic)'), findsOneWidget);
    expect(find.byKey(const Key('session-recovery-card')), findsOneWidget);
    expect(startEvents.length, runtime.timeline.where(
      (SessionTimelineEvent event) => event.type == SessionTimelineEventType.sessionStart,
    ).length);
  });
}
