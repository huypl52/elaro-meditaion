import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elaro_mobile/domain/reflection.dart';
import 'package:elaro_mobile/features/session/session.dart';
import 'package:elaro_mobile/main.dart';
import 'package:elaro_mobile/runtime/reflection_runtime.dart';
import 'package:elaro_mobile/runtime/session.dart';

void main() {
  setUp(() {
    const SessionRuntime().resetForTests();
    ReflectionRuntime.instance.resetForTests();
  });

  Future<void> openSettings(WidgetTester tester) async {
    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed('/settings');
    await tester.pumpAndSettle();
  }

  Future<void> openReflectionWithoutOptIn(WidgetTester tester) async {
    final runtime = const SessionRuntime();
    runtime.startSession(
      sessionRoute: '/session/short-breath',
      manualCheckin: CheckinState.calm,
      sessionDurationSeconds: 45,
      startupMode: 'micro fast',
    );
    runtime.recordComplete(
      sessionId: runtime.lastSessionId,
      elapsedSeconds: 45,
    );

    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(
      '/session/${Uri.encodeComponent(runtime.lastSessionId)}/reflection',
      arguments: <String, Object?>{
        'sessionId': runtime.lastSessionId,
        'sessionRoute': '/session/short-breath',
      },
    );
    await tester.pumpAndSettle();
  }

  testWidgets('settings exposes AI consent boundary and toggle', (tester) async {
    await openSettings(tester);

    expect(find.byKey(const Key('settings-ai-insight-consent')), findsOneWidget);
    expect(find.byKey(const Key('settings-ai-insight-toggle')), findsOneWidget);
    expect(find.textContaining('local fallback'), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings-ai-insight-toggle')));
    await tester.pumpAndSettle();

    expect(AiConsentRuntime.instance.optedIn, isTrue);
    expect(find.textContaining('Đã opt-in AI insight'), findsOneWidget);
  });

  testWidgets('without opt-in reflection stays local and does not use provider handler', (tester) async {
    ReflectionRuntime.instance.setHandlerForTests((summary) async {
      return const ReflectionInsight(
        message: 'Provider should not be used without opt-in.',
        source: 'provider',
      );
    });

    await openReflectionWithoutOptIn(tester);

    expect(find.byKey(const Key('session-reflection-ai-opt-in-copy')), findsOneWidget);
    expect(find.text('Provider should not be used without opt-in.'), findsNothing);

    final cachedInsight = const SessionRuntime()
        .latestReflectionInsightForSession(const SessionRuntime().lastSessionId);
    expect(cachedInsight?.payload['source'], 'local-fallback');
  });
}
