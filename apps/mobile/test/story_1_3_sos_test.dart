import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elaro_mobile/main.dart';
import 'package:elaro_mobile/domain/timeline.dart';
import 'package:elaro_mobile/features/session/session.dart';
import 'package:elaro_mobile/features/sos/sos.dart';
import 'package:elaro_mobile/runtime/dev_gate.dart';
import 'package:elaro_mobile/runtime/sensor_runtime.dart';
import 'package:elaro_mobile/runtime/sos_runtime.dart';
import 'package:elaro_mobile/runtime/session.dart';

void main() {
  setUp(() {
    SensorRuntime.instance.resetForTests();
    SosRuntime.instance.resetForTests();
    const SessionRuntime().resetForTests();
  });

  testWidgets('Home SOS capsule opens safe SOS when context is unavailable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('cta-sos')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sos-safe-btn')), findsOneWidget);
    expect(find.text('Không đủ điều kiện SOS nhanh, chuyển sang calm-safe.'), findsOneWidget);
  });

  testWidgets('Home SOS capsule reads sensor state from runtime', (WidgetTester tester) async {
    SensorRuntime.instance.setSensorAvailableForTests(false);

    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('cta-sos')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sos-safe-btn')), findsOneWidget);
    expect(find.text('Không đủ điều kiện SOS nhanh, chuyển sang calm-safe.'), findsOneWidget);
    expect(find.byKey(const Key('sos-start-btn')), findsNothing);
  });

  testWidgets('Active mode shows 60s flow on SOS start', (WidgetTester tester) async {
    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(
      '/sos',
      arguments: const SosEntryArgs(
        contextSnapshot: CheckinState.low,
        contextAvailable: true,
        sensorAvailable: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sos-start-btn')), findsOneWidget);
    await tester.tap(find.byKey(const Key('sos-start-btn')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sos-active-headline')), findsOneWidget);
    expect(find.byKey(const Key('sos-safe-exit-copy')), findsNothing);
    expect(find.byType(ProgressRing), findsOneWidget);
  });

  testWidgets('Repeated SOS under 60s becomes calm-safe', (WidgetTester tester) async {
    SosRuntime.instance.resetForTests();
    SosRuntime.instance.registerEntry(DateTime.now().subtract(const Duration(seconds: 10)));

    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(
      '/sos',
      arguments: const SosEntryArgs(
        contextSnapshot: CheckinState.low,
        contextAvailable: true,
        sensorAvailable: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sos-safe-btn')), findsOneWidget);
    expect(find.text('Không đủ điều kiện SOS nhanh, chuyển sang calm-safe.'), findsOneWidget);
  });

  testWidgets('Active timeout logs sos_timeout_exit and becomes calm-safe', (WidgetTester tester) async {
    const runtime = SessionRuntime();
    runtime.resetForTests();

    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(
      '/sos',
      arguments: const SosEntryArgs(
        contextSnapshot: CheckinState.low,
        contextAvailable: true,
        sensorAvailable: true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('sos-start-btn')));
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 61));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sos-safe-exit-copy')), findsOneWidget);
    final timeline = runtime.timeline;
    expect(
      timeline.where((SessionTimelineEvent e) => e.type == SessionTimelineEventType.sosTimeoutExit),
      isNotEmpty,
    );
  });

  testWidgets('sos-return-btn exits SOS entry without interrupt', (WidgetTester tester) async {
    const runtime = SessionRuntime();
    runtime.resetForTests();
    SensorRuntime.instance.setSensorAvailableForTests(false);

    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('cta-sos')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('sos-return-btn')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cta-sos')), findsOneWidget);
    expect(runtime.timeline.any((SessionTimelineEvent e) => e.type == SessionTimelineEventType.sosInterrupt), isFalse);
  });

  testWidgets('sos-active-exit records interrupt and returns Home', (WidgetTester tester) async {
    const runtime = SessionRuntime();
    runtime.resetForTests();

    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(
      '/sos',
      arguments: const SosEntryArgs(
        contextSnapshot: CheckinState.low,
        contextAvailable: true,
        sensorAvailable: true,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sos-start-btn')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('sos-active-exit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cta-sos')), findsOneWidget);
    expect(runtime.timeline.any((SessionTimelineEvent e) => e.type == SessionTimelineEventType.sosInterrupt), isTrue);
  });

  testWidgets('sos-exit-btn records interrupt and returns Home', (WidgetTester tester) async {
    const runtime = SessionRuntime();
    runtime.resetForTests();

    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(
      '/sos',
      arguments: const SosEntryArgs(
        contextSnapshot: CheckinState.low,
        contextAvailable: true,
        sensorAvailable: true,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sos-start-btn')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('sos-exit-btn')));
    await tester.tap(find.byKey(const Key('sos-exit-btn')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cta-sos')), findsOneWidget);
    expect(runtime.timeline.where((SessionTimelineEvent e) => e.type == SessionTimelineEventType.sosInterrupt).length, 1);
  });

  testWidgets('sos-calm-safe-return does not record interrupt after timeout-safe entry', (
    WidgetTester tester,
  ) async {
    const runtime = SessionRuntime();
    runtime.resetForTests();

    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(
      '/sos/active',
      arguments: const SosActiveArgs(
        mode: SosMode.calmSafe,
        contextSnapshot: CheckinState.low,
        contextAvailable: true,
        sensorAvailable: true,
        hapticEnabled: true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('sos-calm-safe-return')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cta-sos')), findsOneWidget);
    expect(runtime.timeline.any((SessionTimelineEvent e) => e.type == SessionTimelineEventType.sosInterrupt), isFalse);
  });

  testWidgets('DistressBoundary action opens SupportResources sheet', (WidgetTester tester) async {
    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(
      '/sos',
      arguments: const SosEntryArgs(
        contextSnapshot: null,
        contextAvailable: false,
        sensorAvailable: true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tìm hỗ trợ'));
    await tester.pumpAndSettle();

    expect(find.text('Hotline: 111'), findsOneWidget);
  });

  testWidgets('Reduce-motion or haptic-off shows SOS text fallback', (WidgetTester tester) async {
    SosRuntime.instance.resetForTests();
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: const ElaroMedApp(),
      ),
    );
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(
      '/sos',
      arguments: const SosEntryArgs(
        contextSnapshot: CheckinState.low,
        contextAvailable: true,
        sensorAvailable: true,
        hapticEnabled: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sos-haptic-text-fallback')), findsOneWidget);

    await tester.tap(find.byKey(const Key('sos-start-btn')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sos-haptic-text-fallback')), findsOneWidget);
  });

  testWidgets('Release build hides SOS dev telemetry', (WidgetTester tester) async {
    if (DevGate.enabled) {
      return;
    }

    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(
      '/sos',
      arguments: const SosEntryArgs(
        contextSnapshot: CheckinState.low,
        contextAvailable: true,
        sensorAvailable: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('sos-reason'), findsNothing);

    await tester.tap(find.byKey(const Key('sos-start-btn')));
    await tester.pumpAndSettle();

    expect(find.textContaining('sos-reason'), findsNothing);
  });
}
