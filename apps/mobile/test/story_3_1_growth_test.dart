import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elaro_mobile/features/growth/growth.dart';
import 'package:elaro_mobile/features/session/session.dart';
import 'package:elaro_mobile/main.dart';
import 'package:elaro_mobile/runtime/session.dart';

void main() {
  setUp(() {
    const SessionRuntime().resetForTests();
  });

  Future<void> _openGrowth(WidgetTester tester) async {
    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.insights_outlined));
    await tester.pumpAndSettle();
  }

  test('SessionRuntime totals derive from completed timeline sessions only', () {
    const runtime = SessionRuntime();
    runtime.resetForTests();

    final firstCompleted = runtime.startSession(
      sessionRoute: '/session/short-breath',
      manualCheckin: CheckinState.calm,
      sessionDurationSeconds: 90,
      startupMode: 'micro fast',
    );
    runtime.recordComplete(sessionId: firstCompleted.createdAt.toUtc().toIso8601String(), elapsedSeconds: 90);

    final interrupted = runtime.startSession(
      sessionRoute: '/session/short-breath',
      manualCheckin: CheckinState.low,
      sessionDurationSeconds: 20,
      startupMode: 'micro fast',
    );
    runtime.recordManualExit(
      sessionId: interrupted.createdAt.toUtc().toIso8601String(),
      elapsedSeconds: 10,
      reason: 'manual-exit',
    );

    expect(runtime.totalSessionCount, 1);
    expect(runtime.totalSessionDurationSeconds, 90);
  });

  testWidgets('Growth render shows Vietnamese eyebrow/headline and calm welcome-back copy', (WidgetTester tester) async {
    await _openGrowth(tester);

    expect(find.text('Tiến trình nhẹ nhàng'), findsOneWidget);
    expect(find.text('Bản đồ phát triển'), findsOneWidget);
    expect(find.text(growthWelcomeBackCopy), findsOneWidget);
  });

  testWidgets('StatTile shows total sessions and total duration from runtime totals', (WidgetTester tester) async {
    final runtime = const SessionRuntime();
    final first = runtime.startSession(
      sessionRoute: '/session/short-breath',
      manualCheckin: CheckinState.calm,
      sessionDurationSeconds: 20,
      startupMode: 'micro fast',
    );
    runtime.recordComplete(sessionId: first.createdAt.toIso8601String(), elapsedSeconds: 120);

    final second = runtime.startSession(
      sessionRoute: '/session/short-breath',
      manualCheckin: CheckinState.calm,
      sessionDurationSeconds: 20,
      startupMode: 'micro fast',
    );
    runtime.recordComplete(sessionId: second.createdAt.toIso8601String(), elapsedSeconds: 180);

    await _openGrowth(tester);

    expect(find.text('Tổng phiên: 2'), findsOneWidget);
    expect(find.text('Tổng thời lượng: 5 phút'), findsOneWidget);
  });

  testWidgets('Growth has no streak/score/leaderboard and shows safe no-comparison Bento copy', (
    WidgetTester tester,
  ) async {
    await _openGrowth(tester);

    expect(find.text('streak'), findsNothing);
    expect(find.text('score'), findsNothing);
    expect(find.text('leaderboard'), findsNothing);
    expect(find.text('so sánh người khác'), findsNothing);
    expect(find.text(growthNoComparisonsCopy), findsOneWidget);
  });

  testWidgets('Growth CTAs are present with exact labels', (WidgetTester tester) async {
    await _openGrowth(tester);

    expect(find.byKey(const Key('growth-quick-start')), findsOneWidget);
    expect(find.text('Khởi tạo quick session 20s'), findsOneWidget);
    expect(find.byKey(const Key('growth-open-library')), findsOneWidget);
    expect(find.text('Mở thư viện'), findsOneWidget);
  });
}
