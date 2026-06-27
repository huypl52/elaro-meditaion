import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elaro_mobile/main.dart';

void main() {
  testWidgets('Bottom nav has exactly four Home/Library/Growth/Settings tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    final navBar = find.byType(NavigationBar);
    expect(navBar, findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(find.descendant(of: navBar, matching: find.text('Home')), findsOneWidget);
    expect(find.descendant(of: navBar, matching: find.text('Library')), findsOneWidget);
    expect(find.descendant(of: navBar, matching: find.text('Growth')), findsOneWidget);
    expect(find.descendant(of: navBar, matching: find.text('Settings')), findsOneWidget);
    expect(
      find.descendant(of: navBar, matching: find.byIcon(Icons.home_outlined)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navBar, matching: find.byIcon(Icons.menu_book_outlined)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navBar, matching: find.byIcon(Icons.insights_outlined)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navBar, matching: find.byIcon(Icons.settings_outlined)),
      findsOneWidget,
    );
    expect(find.byKey(const Key('cta-sos')), findsOneWidget);
    expect(find.descendant(of: navBar, matching: find.byKey(const Key('cta-sos'))), findsNothing);
  });

  testWidgets('Home is initial route and unknown routes fallback to home tab scaffold', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('checkin-calm')), findsOneWidget);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed('/unknown-tab');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('checkin-calm')), findsOneWidget);
    expect(find.text('Không tìm thấy route'), findsNothing);
  });

  testWidgets('Navigating tab destinations goes to /home /library /growth /settings', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ElaroMedApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Library'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.insights_outlined));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Growth'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('checkin-calm')), findsOneWidget);
  });
}
