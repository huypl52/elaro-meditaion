import 'package:flutter/material.dart';

import 'features/home/home.dart';
import 'features/session/session.dart';

void main() {
  runApp(const ElaroMedApp());
}

class ElaroMedApp extends StatelessWidget {
  const ElaroMedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elaro',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      initialRoute: '/home',
      onGenerateRoute: _buildRoute,
    );
  }

  Route<dynamic> _buildRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
      case '/sos':
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const _PlaceholderScreen(
            title: 'SOS',
            message: 'Đường vào nhanh để hạ nhịp trong 60 giây.',
          ),
        );
      case '/session/start':
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => SessionStartScreen(args: SessionStartArgs.fromDynamic(settings.arguments)),
        );
      case '/session/short-breath':
      case '/session/before-sleep':
      case '/session/continue':
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => SessionStartScreen(
            args: SessionStartArgs(
              sessionRoute: settings.name ?? '/session/short-breath',
              manualCheckin: null,
            ),
          ),
        );
      case '/session/active':
        final activeArgs = settings.arguments;
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => activeArgs is SessionActiveArgs
              ? SessionActiveScreen(args: activeArgs)
              : const _SessionActiveFallbackScreen(),
        );
      case '/':
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
      default:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
    }
  }
}

class _SessionActiveFallbackScreen extends StatelessWidget {
  const _SessionActiveFallbackScreen();

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderScreen(
      title: 'Session',
      message: 'Không thể mở phiên. Vui lòng thử lại.',
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pushNamed('/home'),
                child: const Text('Về Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
