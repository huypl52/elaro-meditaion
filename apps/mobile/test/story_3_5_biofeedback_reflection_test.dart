import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elaro_mobile/main.dart';
import 'package:elaro_mobile/runtime/session.dart';

void main() {
  setUp(() {
    const SessionRuntime().resetForTests();
  });

  Future<void> openReflection(
    WidgetTester tester, {
    required String sessionId,
    required bool healthPermissionGranted,
    Map<String, Object?>? bio,
  }) async {
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
  }

  testWidgets(
      'high-confidence permitted biofeedback renders enriched tone-word block without raw values',
      (
    WidgetTester tester,
  ) async {
    await openReflection(
      tester,
      sessionId: 'bio-high',
      healthPermissionGranted: true,
      bio: const <String, Object?>{
        'heartRateBpm': 68,
        'movementLevel': 0.1,
        'hrvValue': 32,
        'confidence': 0.82,
      },
    );

    expect(find.text('Phản hồi phiên'), findsOneWidget);
    expect(find.text('Phản hồi cảm nhận nhẹ nhàng'), findsOneWidget);
    expect(find.byKey(const Key('session-reflection-no-pressure')),
        findsOneWidget);
    expect(
        find.byKey(const Key('reflection-distress-boundary')), findsOneWidget);

    expect(find.byKey(const Key('session-reflection-biofeedback-title')),
        findsOneWidget);
    expect(
        find.text('Phản hồi nâng cao từ tín hiệu sinh trắc'), findsOneWidget);
    expect(find.byKey(const Key('session-reflection-biofeedback-body')),
        findsOneWidget);
    expect(find.textContaining('ổn định'), findsWidgets);
    expect(find.textContaining('rất tĩnh'), findsOneWidget);
    expect(find.textContaining('ổn định hơn'), findsOneWidget);
    expect(find.textContaining('đây là chiều hướng, không phải chỉ số'),
        findsOneWidget);

    final body = tester
        .widget<Text>(
            find.byKey(const Key('session-reflection-biofeedback-body')))
        .data!;
    expect(body, isNot(contains('68')));
    expect(body, isNot(contains('32')));
    expect(body, isNot(contains('0.82')));
    expect(body, isNot(contains('bpm')));
    expect(body, isNot(contains('%')));
    expect(body.toLowerCase(), isNot(contains('score')));
    expect(body.toLowerCase(), isNot(contains('rank')));
    expect(body, isNot(contains('điểm')));
    expect(body, isNot(contains('so sánh')));
  });

  testWidgets(
      'tone mapping covers elevated HR, gentle movement, and recovering HRV words',
      (
    WidgetTester tester,
  ) async {
    await openReflection(
      tester,
      sessionId: 'bio-tone',
      healthPermissionGranted: true,
      bio: const <String, Object?>{
        'heartRateBpm': 98,
        'movementLevel': 0.45,
        'hrvValue': 18,
        'confidence': 0.7,
      },
    );

    expect(find.byKey(const Key('session-reflection-biofeedback-body')),
        findsOneWidget);
    expect(find.textContaining('hơi dồn dập'), findsOneWidget);
    expect(find.textContaining('dịu dịu'), findsOneWidget);
    expect(find.textContaining('đang hồi dần'), findsOneWidget);
  });

  testWidgets(
      'low-confidence biofeedback shows non-shaming fallback and no enriched title',
      (
    WidgetTester tester,
  ) async {
    await openReflection(
      tester,
      sessionId: 'bio-low',
      healthPermissionGranted: true,
      bio: const <String, Object?>{
        'heartRateBpm': 74,
        'movementLevel': 0.7,
        'hrvValue': 25,
        'confidence': 0.42,
      },
    );

    expect(find.byKey(const Key('session-reflection-biofeedback-low')),
        findsOneWidget);
    expect(find.textContaining('Tín hiệu sinh trắc lúc này chưa đủ rõ'),
        findsOneWidget);
    expect(find.textContaining('hãy quay lại với cảm nhận của bạn'),
        findsOneWidget);
    expect(find.byKey(const Key('session-reflection-biofeedback-title')),
        findsNothing);
    expect(find.byKey(const Key('session-reflection-biofeedback-body')),
        findsNothing);
    expect(find.textContaining('0.42'), findsNothing);
  });

  testWidgets(
      'missing permission or missing biofeedback shows baseline fallback', (
    WidgetTester tester,
  ) async {
    await openReflection(
      tester,
      sessionId: 'bio-no-permission',
      healthPermissionGranted: false,
      bio: const <String, Object?>{
        'heartRateBpm': 68,
        'movementLevel': 0.1,
        'hrvValue': 32,
        'confidence': 0.95,
      },
    );

    expect(find.byKey(const Key('session-reflection-biofeedback-fallback')),
        findsOneWidget);
    expect(
        find.textContaining('dữ liệu sinh trắc chưa sẵn sàng'), findsOneWidget);
    expect(find.byKey(const Key('session-reflection-biofeedback-title')),
        findsNothing);

    await openReflection(
      tester,
      sessionId: 'bio-null',
      healthPermissionGranted: true,
    );

    expect(find.byKey(const Key('session-reflection-biofeedback-fallback')),
        findsOneWidget);
    expect(find.byKey(const Key('session-reflection-biofeedback-title')),
        findsNothing);
  });

  testWidgets('reflection does not expose synthetic biofeedback QA controls', (
    WidgetTester tester,
  ) async {
    await openReflection(
      tester,
      sessionId: 'bio-no-controls',
      healthPermissionGranted: true,
      bio: const <String, Object?>{
        'heartRateBpm': 72,
        'movementLevel': 0.8,
        'hrvValue': 30,
        'confidence': 0.9,
      },
    );

    expect(
        find.byKey(const Key('session-bio-permission-enable')), findsNothing);
    expect(
        find.byKey(const Key('session-bio-permission-disable')), findsNothing);
    expect(find.textContaining('DEV • biofeedback'), findsNothing);
    expect(find.textContaining('confidence'), findsNothing);
  });
}
