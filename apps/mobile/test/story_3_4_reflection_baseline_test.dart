import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elaro_mobile/features/session/session.dart';
import 'package:elaro_mobile/main.dart';
import 'package:elaro_mobile/runtime/session.dart';

void main() {
  setUp(() {
    const SessionRuntime().resetForTests();
  });

  Future<void> openReflection(
    WidgetTester tester, {
    required String sessionId,
    String sessionRoute = '/session/short-breath',
  }) async {
    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(
      '/session/${Uri.encodeComponent(sessionId)}/reflection',
      arguments: SessionReflectionArgs(
        sessionId: sessionId,
        sessionRoute: sessionRoute,
      ),
    );
    await tester.pumpAndSettle();
  }

  void recordCompletedSession(String sessionId, int elapsedSeconds) {
    const SessionRuntime().recordComplete(
      sessionId: sessionId,
      elapsedSeconds: elapsedSeconds,
      at: DateTime.utc(2026, 6, 27, 8),
    );
  }

  testWidgets('reflection renders baseline title, eyebrow, headline and no-pressure copy', (
    WidgetTester tester,
  ) async {
    recordCompletedSession('session-45', 45);

    await openReflection(tester, sessionId: 'session-45');

    expect(find.text('Phản hồi phiên'), findsOneWidget);
    expect(find.text('Sau phiên'), findsOneWidget);
    expect(find.text('Phản hồi cảm nhận nhẹ nhàng'), findsOneWidget);
    expect(find.byKey(const Key('session-reflection-no-pressure')), findsOneWidget);
    expect(find.text('Tổng kết nhẹ: không đưa ra điểm số, không so sánh…'), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
    expect(find.textContaining('rank'), findsNothing);
    expect(find.textContaining('leaderboard'), findsNothing);
  });

  testWidgets('reflection narrative trend uses duration bands without absolute scoring', (
    WidgetTester tester,
  ) async {
    recordCompletedSession('session-short', 45);
    recordCompletedSession('session-medium', 90);
    recordCompletedSession('session-long', 180);

    await openReflection(tester, sessionId: 'session-short');
    expect(find.text('Bạn đã chạm một khoảng dừng ngắn và đủ để nhận lại nhịp thở.'), findsOneWidget);

    await openReflection(tester, sessionId: 'session-medium');
    expect(find.text('Bạn đã duy trì sự tĩnh tại ở một chu kỳ tương đối ổn định.'), findsOneWidget);

    await openReflection(tester, sessionId: 'session-long');
    expect(find.text('Bạn đã ở lại lâu hơn với nhịp của mình, theo cách không cần đo đếm.'), findsOneWidget);
  });

  testWidgets('reflection no-state fallback remains narrative only', (WidgetTester tester) async {
    await openReflection(tester, sessionId: 'missing-session');

    expect(find.text('Phiên này chưa có đủ dấu mốc, hãy xem đây như một ghi chú nhẹ về cảm nhận hiện tại.'), findsOneWidget);
    expect(find.textContaining('điểm'), findsOneWidget);
    expect(find.textContaining('100'), findsNothing);
    expect(find.textContaining('%'), findsNothing);
    expect(find.textContaining('score'), findsNothing);
    expect(find.textContaining('rank'), findsNothing);
    expect(find.textContaining('leaderboard'), findsNothing);
  });

  testWidgets('completed-session re-entry follow-up opens reflection baseline', (
    WidgetTester tester,
  ) async {
    recordCompletedSession('session-reentry', 90);

    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(
      '/session/${Uri.encodeComponent('session-reentry')}/re-entry',
      arguments: const SessionReEntryArgs(
        sessionId: 'session-reentry',
        sessionRoute: '/session/short-breath',
        manualCheckin: CheckinState.calm,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('session-reentry-followup')));
    await tester.pumpAndSettle();

    expect(find.text('Phản hồi phiên'), findsOneWidget);
    expect(find.text('Bạn đã duy trì sự tĩnh tại ở một chu kỳ tương đối ổn định.'), findsOneWidget);
  });

  testWidgets('reflection distress boundary opens support sheet', (WidgetTester tester) async {
    recordCompletedSession('session-support', 90);

    await openReflection(tester, sessionId: 'session-support');

    expect(find.byKey(const Key('reflection-distress-boundary')), findsOneWidget);
    expect(find.text('Đây là công cụ tự chăm sóc nhẹ nhàng, không thay thế hỗ trợ chuyên môn…'), findsOneWidget);

    await tester.tap(find.text('Tìm hỗ trợ'));
    await tester.pumpAndSettle();

    expect(find.text('Hotline: 111'), findsOneWidget);
  });

  testWidgets('reflection return CTA navigates back to Home', (WidgetTester tester) async {
    recordCompletedSession('session-return', 90);

    await openReflection(tester, sessionId: 'session-return');
    await tester.ensureVisible(find.byKey(const Key('session-reflection-return')));
    await tester.tap(find.byKey(const Key('session-reflection-return')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('checkin-calm')), findsOneWidget);
  });
}
