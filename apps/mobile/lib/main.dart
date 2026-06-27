import 'package:flutter/material.dart';

import 'features/home/home.dart';

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
      case '/session/short-breath':
      case '/session/before-sleep':
      case '/session/continue':
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => _SessionPlaceholderScreen(route: settings.name ?? ''),
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

class _SessionPlaceholderScreen extends StatelessWidget {
  const _SessionPlaceholderScreen({required this.route});

  final String route;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Session route: $route'),
        ),
      ),
    );
  }
}
