import 'package:flutter/material.dart';

import 'package:elaro_mobile/features/growth/growth.dart';
import 'package:elaro_mobile/features/home/home.dart';
import 'package:elaro_mobile/features/session/session.dart';
import 'package:elaro_mobile/features/sos/sos.dart';
import 'package:elaro_mobile/features/voice_journal/voice_journal.dart';
import 'package:elaro_mobile/runtime/sos_runtime.dart';

void main() {
  runApp(const ElaroMedApp());
}

class ElaroMedApp extends StatelessWidget {
  const ElaroMedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elaro',
      initialRoute: '/home',
      onGenerateRoute: _buildRoute,
    );
  }

  static Route<dynamic> _buildRoute(RouteSettings settings) {
    final String routeName = settings.name ?? '/';
    final String canonicalRoute = routeName == '/' ? '/home' : routeName;

    if (_isTabRoute(canonicalRoute)) {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => _TabScaffold(selectedRoute: canonicalRoute),
      );
    }

    switch (canonicalRoute) {
      case '/sos':
        final args = SosEntryArgs.fromDynamic(settings.arguments);
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SosEntryScreen(args: args),
        );
      case '/sos/active':
        final args = SosActiveArgs.fromDynamic(settings.arguments);
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SosActiveScreen(args: args),
        );
      case '/session/start':
        final args = SessionStartArgs.fromDynamic(settings.arguments);
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SessionStartScreen(args: args),
        );
      case '/session/active':
        final args = settings.arguments;
        if (args is! SessionActiveArgs) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => _TabScaffold(selectedRoute: '/home'),
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SessionActiveScreen(args: args),
        );
      case '/voice-journal':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const VoiceJournalScreen(),
        );
    }

    final reentryMatch = RegExp(r'^/session/(.+)/re-entry$').firstMatch(canonicalRoute);
    if (reentryMatch != null) {
      final reentryArgs = SessionReEntryArgs.fromDynamic(
        settings.arguments,
        fallbackSessionRoute: '/session/short-breath',
      );
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => SessionReEntryScreen(
          args: SessionReEntryArgs(
            sessionId: Uri.decodeComponent(reentryMatch.group(1)!),
            sessionRoute: reentryArgs.sessionRoute,
            manualCheckin: reentryArgs.manualCheckin,
            hasMicrophone: reentryArgs.hasMicrophone,
          ),
        ),
      );
    }

    final reflectionMatch = RegExp(r'^/session/(.+)/reflection$').firstMatch(canonicalRoute);
    if (reflectionMatch != null) {
      final reflectionArgs = SessionReflectionArgs.fromDynamic(
        settings.arguments,
        fallbackSessionRoute: '/session/short-breath',
      );
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => SessionReflectionScreen(
          args: SessionReflectionArgs(
            sessionId: Uri.decodeComponent(reflectionMatch.group(1)!),
            sessionRoute: reflectionArgs.sessionRoute,
          ),
        ),
      );
    }

    return MaterialPageRoute(
      settings: settings,
      builder: (_) => _TabScaffold(selectedRoute: '/home'),
    );
  }
}

class _TabDestination {
  const _TabDestination({
    required this.route,
    required this.label,
    required this.icon,
    required this.builder,
  });

  final String route;
  final String label;
  final IconData icon;
  final WidgetBuilder builder;
}

final List<_TabDestination> _kTabDestinations = [
  _TabDestination(
    route: '/home',
    label: 'Home',
    icon: Icons.home_outlined,
    builder: (_) => const HomeScreen(),
  ),
  _TabDestination(
    route: '/library',
    label: 'Library',
    icon: Icons.menu_book_outlined,
    builder: (_) => const _LibraryScreen(),
  ),
  _TabDestination(
    route: '/growth',
    label: 'Growth',
    icon: Icons.insights_outlined,
    builder: (_) => const GrowthScreen(),
  ),
  _TabDestination(
    route: '/settings',
    label: 'Settings',
    icon: Icons.settings_outlined,
    builder: (_) => const _SettingsScreen(),
  ),
];

bool _isTabRoute(String route) {
  return _kTabDestinations.any((destination) => destination.route == route);
}

class _TabScaffold extends StatelessWidget {
  const _TabScaffold({required this.selectedRoute});

  final String selectedRoute;

  int get _selectedIndex {
    final int index = _kTabDestinations.indexWhere(
      (destination) => destination.route == selectedRoute,
    );
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _kTabDestinations[_selectedIndex].builder(context),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          final destination = _kTabDestinations[index];
          if (destination.route == selectedRoute) {
            return;
          }
          Navigator.of(context).pushReplacementNamed(destination.route);
        },
        destinations: [
          for (final destination in _kTabDestinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}

class _LibraryScreen extends StatelessWidget {
  const _LibraryScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Text('Library'),
        ],
      ),
    );
  }
}

class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Text('Settings'),
        ],
      ),
    );
  }
}
