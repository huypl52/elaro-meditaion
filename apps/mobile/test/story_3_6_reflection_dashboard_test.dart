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

  Future<String> seedSession({
    EnvironmentalContextSnapshot? environmentalContext,
  }) async {
    final runtime = const SessionRuntime();
    runtime.startSession(
      sessionRoute: '/session/short-breath',
      manualCheckin: CheckinState.calm,
      sessionDurationSeconds: 90,
      startupMode: 'standard',
      environmentalContext: environmentalContext,
    );
    final sessionId = runtime.lastSessionId;
    runtime.recordComplete(sessionId: sessionId, elapsedSeconds: 90);
    return sessionId;
  }

  Future<String> openReflection(
    WidgetTester tester, {
    required bool healthPermissionGranted,
    Map<String, Object?>? bio,
    EnvironmentalContextSnapshot? environmentalContext,
  }) async {
    final sessionId = await seedSession(environmentalContext: environmentalContext);
    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(
      '/session/${Uri.encodeComponent(sessionId)}/reflection',
      arguments: <String, Object?>{
        'sessionId': sessionId,
        'sessionRoute': '/session/short-breath',
        'healthPermissionGranted': healthPermissionGranted,
        'bio': bio,
      },
    );
    await tester.pumpAndSettle();
    return sessionId;
  }

  testWidgets('dashboard renders context and biofeedback correlation with local fallback insight by default', (tester) async {
    final sessionId = await openReflection(
      tester,
      healthPermissionGranted: true,
      environmentalContext: const EnvironmentalContextSnapshot(
        contextTag: 'urban-vibe',
        confidence: 0.82,
        relativeNoiseLevel: 0.9,
        soundClassification: 'busy-street',
      ),
      bio: const <String, Object?>{
        'heartRateBpm': 68,
        'movementLevel': 0.1,
        'hrvValue': 32,
        'confidence': 0.82,
      },
    );

    expect(find.byKey(const Key('session-reflection-dashboard')), findsOneWidget);
    expect(find.byKey(const Key('session-reflection-environment-chip')), findsOneWidget);
    expect(find.byKey(const Key('session-reflection-bio-chip')), findsOneWidget);
    expect(find.byKey(const Key('session-reflection-dashboard-correlation')), findsOneWidget);
    expect(find.byKey(const Key('session-reflection-ai-opt-in-copy')), findsOneWidget);
    expect(find.byKey(const Key('session-reflection-ai-message-card')), findsOneWidget);
    expect(find.textContaining('Môi trường quanh bạn có vẻ hơi dày tín hiệu'), findsOneWidget);

    final cachedInsight = const SessionRuntime()
        .latestReflectionInsightForSession(sessionId);
    expect(cachedInsight?.payload['source'], 'local-fallback');
  });

  testWidgets('opted-in AI insight uses provider handler and sanitized payload', (tester) async {
    AiConsentRuntime.instance.setOptedIn(true);
    ReflectionRuntime.instance.setHandlerForTests((summary) async {
      return const ReflectionInsight(
        message: 'Bạn đã giữ được một vùng chú ý dịu và không cần ép thêm.',
        source: 'provider',
      );
    });

    final sessionId = await openReflection(
      tester,
      healthPermissionGranted: false,
      environmentalContext: const EnvironmentalContextSnapshot(
        contextTag: 'nature',
        confidence: 0.68,
        relativeNoiseLevel: 0.4,
        soundClassification: 'steady-breath',
      ),
    );

    expect(find.byKey(const Key('session-reflection-ai-opt-in-copy')), findsNothing);
    expect(find.byKey(const Key('session-reflection-ai-message-card')), findsOneWidget);
    expect(find.text('Bạn đã giữ được một vùng chú ý dịu và không cần ép thêm.'), findsOneWidget);

    final payload = ReflectionRuntime.instance.lastPayloadForTests;
    expect(payload, isNotNull);
    expect(payload!['raw_audio'], isNull);
    expect(payload['raw_health_samples'], isNull);
    expect(payload['environmental_context'], isA<Map<String, Object?>>());
    expect(payload['session_route'], '/session/short-breath');

    final cachedInsight = const SessionRuntime()
        .latestReflectionInsightForSession(sessionId);
    expect(cachedInsight?.payload['source'], 'provider');
  });
}
