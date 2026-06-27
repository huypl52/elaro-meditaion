import 'package:flutter/material.dart';

import 'package:elaro_mobile/features/home/home.dart';
import 'package:elaro_mobile/features/session/session.dart';
import 'package:elaro_mobile/features/sos/sos.dart';
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
      onGenerateRoute: _onGenerateRoute,
    );
  }

  static Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/home':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
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
            builder: (_) => const Scaffold(
              body: Center(child: Text('Không tìm thấy phiên active')),
            ),
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SessionActiveScreen(args: args),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Không tìm thấy route'),
            ),
          ),
        );
    }
  }
}
