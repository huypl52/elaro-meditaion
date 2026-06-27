import 'package:flutter/material.dart';
import 'package:elaro_mobile/runtime/session.dart';

import '../../domain/timeline.dart';

enum CheckinState {
  calm('calm', 'Ấm/nhẹ'),
  low('low', 'Mệt'),
  overload('overload', 'Quá tải');

  const CheckinState(this.value, this.label);

  final String value;
  final String label;

  static CheckinState? fromName(String? name) {
    for (final state in CheckinState.values) {
      if (state.value == name) return state;
    }
    return null;
  }
}

class SessionStartArgs {
  const SessionStartArgs({
    required this.sessionRoute,
    required this.manualCheckin,
    this.simulateNoMicrophone = false,
    this.simulateLowConfidence = false,
  });

  final String sessionRoute;
  final CheckinState? manualCheckin;
  final bool simulateNoMicrophone;
  final bool simulateLowConfidence;

  factory SessionStartArgs.fromDynamic(Object? args) {
    if (args is SessionStartArgs) {
      return args;
    }

    if (args is Map) {
      return SessionStartArgs(
        sessionRoute: args['sessionRoute'] as String? ?? '/session/short-breath',
        manualCheckin: CheckinState.fromName(args['manualCheckin'] as String?),
        simulateNoMicrophone: args['simulateNoMicrophone'] as bool? ?? false,
        simulateLowConfidence: args['simulateLowConfidence'] as bool? ?? false,
      );
    }

    if (args is String && args.isNotEmpty) {
      return SessionStartArgs(sessionRoute: args, manualCheckin: null);
    }

    return const SessionStartArgs(sessionRoute: '/session/short-breath', manualCheckin: null);
  }
}

class SessionActiveArgs {
  const SessionActiveArgs({
    required this.startEvent,
    required this.timerState,
  });

  final SessionStartEvent startEvent;
  final SessionTimerState timerState;
}

class SessionStartScreen extends StatelessWidget {
  const SessionStartScreen({super.key, required this.args});

  final SessionStartArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bắt đầu phiên')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Phiên: ${args.sessionRoute}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Check-in: ${args.manualCheckin?.label ?? 'Không chọn'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('session-start-button'),
                onPressed: () {
                  final runtime = const SessionRuntime();
                  final event = runtime.startSession(
                    sessionRoute: args.sessionRoute,
                    manualCheckin: args.manualCheckin,
                  );
                  final timerState = SessionTimerState.fromStartEvent(
                    event.toJson(),
                    hasMicrophone: !args.simulateNoMicrophone,
                    noiseConfidence: args.simulateLowConfidence ? 0.2 : null,
                  );
                  Navigator.of(context).pushNamed(
                    '/session/active',
                    arguments: SessionActiveArgs(
                      startEvent: event,
                      timerState: timerState,
                    ),
                  );
                },
                child: const Text('Bắt đầu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SessionActiveScreen extends StatelessWidget {
  const SessionActiveScreen({super.key, required this.args});

  final SessionActiveArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phiên đang chạy')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('manual_checkin: ${args.startEvent.manualCheckin}'),
            const SizedBox(height: 8),
            Text('noise_context_label: ${args.timerState.noiseContextLabel}'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pushNamed('/home'),
              child: const Text('Về Home'),
            ),
          ],
        ),
      ),
    );
  }
}
