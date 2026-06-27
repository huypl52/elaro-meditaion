import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elaro_mobile/domain/timeline.dart';
import 'package:elaro_mobile/features/session/session.dart';
import 'package:elaro_mobile/main.dart';
import 'package:elaro_mobile/runtime/session.dart';

void main() {
  setUp(() {
    const SessionRuntime().resetForTests();
  });

  Future<void> _openVoiceJournal(WidgetTester tester) async {
    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed('/voice-journal');
    await tester.pumpAndSettle();
  }

  testWidgets(
      'Voice journal renders session fallback and disables recording without a session',
      (
    WidgetTester tester,
  ) async {
    await _openVoiceJournal(tester);

    expect(find.text('Nhật ký giọng nói sau phiên'), findsOneWidget);
    expect(find.byKey(const Key('voice-journal-session')), findsOneWidget);
    expect(find.text('Gán cho phiên: none'), findsOneWidget);
    expect(find.byKey(const Key('voice-journal-private')), findsOneWidget);
    expect(find.text('Private scope'), findsOneWidget);
    expect(find.text('Mặc định true'), findsOneWidget);
    expect(
        find.byKey(const Key('voice-journal-no-transcript')), findsOneWidget);
    expect(
      find.text(
          'Bản ghi riêng tư: không tự động chuyển văn bản — chỉ lưu âm thanh gắn với phiên.'),
      findsOneWidget,
    );

    final recordButton = tester.widget<FilledButton>(
      find.byKey(const Key('voice-journal-record')),
    );
    expect(recordButton.onPressed, isNull);
  });

  testWidgets(
      'Voice journal records once, saves private audio, and appends journal timeline event',
      (
    WidgetTester tester,
  ) async {
    const runtime = SessionRuntime();
    final startEvent = runtime.startSession(
      sessionRoute: '/session/short-breath',
      manualCheckin: CheckinState.calm,
      sessionDurationSeconds: 20,
      startupMode: 'test',
    );
    final sessionId = startEvent.createdAt.toUtc().toIso8601String();

    await _openVoiceJournal(tester);

    expect(find.text('Gán cho phiên: $sessionId'), findsOneWidget);
    expect(find.text('Ghi 1 lần'), findsOneWidget);

    await tester.tap(find.byKey(const Key('voice-journal-record')));
    await tester.pumpAndSettle();
    expect(find.text('Dừng ghi'), findsOneWidget);

    await tester.tap(find.byKey(const Key('voice-journal-record')));
    await tester.pumpAndSettle();

    expect(find.text('Ghi 1 lần'), findsOneWidget);
    expect(find.text('Đã lưu 1 bản ghi riêng tư.'), findsOneWidget);

    final journalEvents = runtime.timeline.where(
      (SessionTimelineEvent event) => event.toJson()['type'] == 'journal',
    );
    expect(journalEvents, hasLength(1));

    final payload = journalEvents.single.payload;
    expect(payload[sessionIdTimelineKey], sessionId);
    expect(payload['private'], isTrue);
    expect(payload['transcribe_allowed'], isFalse);
    expect(payload['has_transcript'], isFalse);
  });
}
