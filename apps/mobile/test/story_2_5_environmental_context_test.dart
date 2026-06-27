import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elaro_mobile/features/session/session.dart';
import 'package:elaro_mobile/main.dart';
import 'package:elaro_mobile/runtime/microphone_permission_runtime.dart';
import 'package:elaro_mobile/runtime/reflection_runtime.dart';
import 'package:elaro_mobile/runtime/session.dart';

void main() {
  setUp(() {
    const SessionRuntime().resetForTests();
    MicrophonePermissionRuntime.instance.resetForTests();
    ReflectionRuntime.instance.resetForTests();
  });

  Future<void> openSessionStart(
    WidgetTester tester, {
    required SessionStartArgs args,
  }) async {
    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed('/session/start', arguments: args);
    await tester.pumpAndSettle();
  }

  testWidgets('high-confidence context renders tag, suggestion, dismiss, and persists summary to timeline', (tester) async {
    await openSessionStart(
      tester,
      args: const SessionStartArgs(
        sessionRoute: '/session/short-breath',
        manualCheckin: CheckinState.overload,
        hasMicrophone: true,
      ),
    );

    expect(find.byKey(const Key('session-environmental-context-tag')), findsOneWidget);
    expect(find.text('Urban Vibe'), findsOneWidget);
    expect(find.byKey(const Key('session-soundscape-suggestion-card')), findsOneWidget);
    expect(find.byKey(const Key('session-soundscape-dismiss')), findsOneWidget);
    expect(find.textContaining('busy-street'), findsOneWidget);

    await tester.tap(find.byKey(const Key('session-soundscape-dismiss')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('session-soundscape-suggestion-card')), findsNothing);

    await tester.tap(find.byKey(const Key('session-start-button')));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    final timeline = const SessionRuntime().timeline;
    expect(timeline, isNotEmpty);
    final start = timeline.first;
    expect(start.payload['context_tag'], 'urban-vibe');
    expect(start.payload['sound_classification'], 'busy-street');
  });

  testWidgets('missing microphone or low confidence falls back to manual context without sensor claim', (tester) async {
    await openSessionStart(
      tester,
      args: const SessionStartArgs(
        sessionRoute: '/session/short-breath',
        manualCheckin: CheckinState.low,
        hasMicrophone: false,
      ),
    );

    expect(find.byKey(const Key('session-environmental-manual-context')), findsOneWidget);
    expect(find.textContaining('manual-low'), findsOneWidget);
    expect(find.text('độ tin cậy thấp'), findsOneWidget);
    expect(find.byKey(const Key('session-environmental-context-tag')), findsNothing);
    expect(find.byKey(const Key('session-soundscape-suggestion-card')), findsNothing);
  });
}
