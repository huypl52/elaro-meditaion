import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elaro_mobile/domain/timeline.dart';
import 'package:elaro_mobile/features/ritual/ritual.dart';
import 'package:elaro_mobile/main.dart';
import 'package:elaro_mobile/runtime/session.dart';

void main() {
  setUp(() {
    const SessionRuntime().resetForTests();
    resetRitualRuntimeForTests();
  });

  Future<void> openRoute(WidgetTester tester, String route) async {
    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(route);
    await tester.pumpAndSettle();
  }

  Future<void> createRitual(
    WidgetTester tester, {
    required String name,
    required List<String> itemKeys,
  }) async {
    await openRoute(tester, '/rituals/builder');
    await tester.enterText(find.byKey(const Key('ritual-name')), name);
    for (final key in itemKeys) {
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const Key('ritual-save-btn')));
    await tester.pumpAndSettle();
  }

  testWidgets(
      'Builder renders exact title, name field, step pool, and disabled validation',
      (
    WidgetTester tester,
  ) async {
    await openRoute(tester, '/rituals/builder');

    expect(find.text('Ritual Builder'), findsOneWidget);
    expect(find.byKey(const Key('ritual-name')), findsOneWidget);
    expect(find.text('Tên ritual'), findsOneWidget);
    expect(find.text('Chọn tối thiểu 1 bước'), findsOneWidget);

    const expectedSteps = <String, String>{
      'ritual-item-tho-sau-10-nhip': 'Thở sâu 10 nhịp',
      'ritual-item-tha-long-vai': 'Thả lỏng vai',
      'ritual-item-nham-mat': 'Nhắm mắt',
      'ritual-item-nghe-am-thanh-nen': 'Nghe âm thanh nền',
      'ritual-item-mo-mat-tu-ton': 'Mở mắt từ tốn',
    };
    for (final entry in expectedSteps.entries) {
      expect(find.byKey(Key(entry.key)), findsOneWidget);
      expect(find.text(entry.value), findsOneWidget);
    }

    final missingEverythingButton = tester.widget<FilledButton>(
      find.byKey(const Key('ritual-save-btn')),
    );
    expect(missingEverythingButton.onPressed, isNull);

    await tester.enterText(find.byKey(const Key('ritual-name')), 'Buổi sáng');
    await tester.pumpAndSettle();
    final missingStepButton = tester.widget<FilledButton>(
      find.byKey(const Key('ritual-save-btn')),
    );
    expect(missingStepButton.onPressed, isNull);

    await tester.tap(find.byKey(const Key('ritual-item-tho-sau-10-nhip')));
    await tester.pumpAndSettle();
    final readyButton = tester.widget<FilledButton>(
      find.byKey(const Key('ritual-save-btn')),
    );
    expect(readyButton.onPressed, isNotNull);
  });

  testWidgets(
      'Saving computes estimated duration and replay start carries ritual duration',
      (
    WidgetTester tester,
  ) async {
    await createRitual(
      tester,
      name: 'Buổi sáng',
      itemKeys: const [
        'ritual-item-tho-sau-10-nhip',
        'ritual-item-tha-long-vai',
      ],
    );

    await openRoute(tester, '/ritual/replay');
    expect(find.byKey(const Key('ritual-replay-title')), findsOneWidget);
    expect(find.text('Ritual: Buổi sáng'), findsOneWidget);

    await tester.tap(find.byKey(const Key('ritual-replay-btn')));
    await tester.pumpAndSettle();
    expect(find.text('Bắt đầu phiên'), findsOneWidget);

    await tester.tap(find.byKey(const Key('session-start-button')));
    await tester.pumpAndSettle();

    final startEvents = const SessionRuntime().timeline.where(
          (SessionTimelineEvent event) =>
              event.type == SessionTimelineEventType.sessionStart,
        );
    expect(startEvents, hasLength(1));
    expect(startEvents.single.payload[sessionDurationTimelineKey], 35);
    expect(startEvents.single.payload['session_route'], '/ritual/replay');
  });

  testWidgets('Replay always uses the latest saved ritual',
      (WidgetTester tester) async {
    await createRitual(
      tester,
      name: 'Ritual cũ',
      itemKeys: const ['ritual-item-tho-sau-10-nhip'],
    );
    await createRitual(
      tester,
      name: 'Ritual mới',
      itemKeys: const ['ritual-item-nham-mat'],
    );

    await openRoute(tester, '/ritual/replay');

    expect(find.text('Ritual: Ritual mới'), findsOneWidget);
    expect(find.text('Ritual: Ritual cũ'), findsNothing);
  });

  testWidgets('Empty replay shows empty state and CTA to builder',
      (WidgetTester tester) async {
    await openRoute(tester, '/ritual/replay');

    expect(find.byKey(const Key('ritual-empty')), findsOneWidget);
    expect(find.text('Không có ritual nào'), findsOneWidget);
    expect(find.byKey(const Key('ritual-empty-create')), findsOneWidget);

    await tester.tap(find.byKey(const Key('ritual-empty-create')));
    await tester.pumpAndSettle();
    expect(find.text('Ritual Builder'), findsOneWidget);
  });

  testWidgets(
      'Home row exposes create/replay actions and disables replay when empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-ritual-builder')), findsOneWidget);
    expect(find.text('Tạo ritual mới'), findsOneWidget);
    expect(find.byKey(const Key('home-ritual-replay')), findsOneWidget);
    expect(find.text('Phát lại ritual gần nhất'), findsOneWidget);
    expect(find.byKey(const Key('home-ritual-meta')), findsOneWidget);
    expect(find.text('Chưa có ritual nào'), findsOneWidget);

    final emptyReplay = tester.widget<OutlinedButton>(
      find.byKey(const Key('home-ritual-replay')),
    );
    expect(emptyReplay.onPressed, isNull);

    await tester.tap(find.byKey(const Key('home-ritual-builder')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('ritual-name')), 'Buổi tối');
    await tester.tap(find.byKey(const Key('ritual-item-mo-mat-tu-ton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ritual-save-btn')));
    await tester.pumpAndSettle();

    expect(find.text('Gần nhất: Buổi tối • 20s'), findsOneWidget);
    final readyReplay = tester.widget<OutlinedButton>(
      find.byKey(const Key('home-ritual-replay')),
    );
    expect(readyReplay.onPressed, isNotNull);
  });
}
