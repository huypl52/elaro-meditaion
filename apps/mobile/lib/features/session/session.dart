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
      if (state.value == name) {
        return state;
      }
    }

    return null;
  }
}

enum _StartupMode {
  microFast('micro fast', Duration(milliseconds: 250)),
  standard('standard', Duration(milliseconds: 1100));

  const _StartupMode(this.label, this.startupDelay);

  final String label;
  final Duration startupDelay;

  static _StartupMode fromDuration(int durationSeconds) {
    return durationSeconds <= 90 ? _StartupMode.microFast : _StartupMode.standard;
  }
}

class SessionStartArgs {
  static const List<int> microSessionDurations = <int>[20, 45, 90, 180];
  static const int defaultDurationSeconds = 180;

  const SessionStartArgs({
    required this.sessionRoute,
    required this.manualCheckin,
    this.simulateNoMicrophone = false,
    this.simulateLowConfidence = false,
    this.sessionDurationSeconds = defaultDurationSeconds,
  });

  final String sessionRoute;
  final CheckinState? manualCheckin;
  final bool simulateNoMicrophone;
  final bool simulateLowConfidence;
  final int sessionDurationSeconds;

  factory SessionStartArgs.fromDynamic(Object? args) {
    if (args is SessionStartArgs) {
      return args;
    }

    if (args is Map) {
      final dynamicArgDuration = args['sessionDurationSeconds'];
      final parsedDuration = dynamicArgDuration is int
          ? dynamicArgDuration
          : dynamicArgDuration is num
              ? dynamicArgDuration.toInt()
              : SessionStartArgs.defaultDurationSeconds;

      return SessionStartArgs(
        sessionRoute: args['sessionRoute'] as String? ?? '/session/short-breath',
        manualCheckin: CheckinState.fromName(args['manualCheckin'] as String?),
        simulateNoMicrophone: args['simulateNoMicrophone'] as bool? ?? false,
        simulateLowConfidence: args['simulateLowConfidence'] as bool? ?? false,
        sessionDurationSeconds: parsedDuration,
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

class SessionStartScreen extends StatefulWidget {
  const SessionStartScreen({super.key, required this.args});

  final SessionStartArgs args;

  @override
  State<SessionStartScreen> createState() => _SessionStartScreenState();
}

class _SessionStartScreenState extends State<SessionStartScreen> {
  late int _selectedDurationSeconds;
  bool _isStarting = false;
  _StartupMode _currentStartupMode = _StartupMode.standard;

  @override
  void initState() {
    super.initState();
    _selectedDurationSeconds = widget.args.sessionDurationSeconds;
    _currentStartupMode = _StartupMode.fromDuration(_selectedDurationSeconds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bắt đầu phiên')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Phiên: ${widget.args.sessionRoute}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Check-in: ${widget.args.manualCheckin?.label ?? 'Không chọn'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Chọn micro session',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                for (final duration in SessionStartArgs.microSessionDurations)
                  ChoiceChip(
                    key: Key(_durationChipKey(duration)),
                    label: Text(_durationChipLabel(duration)),
                    selected: _selectedDurationSeconds == duration,
                    onSelected: (_) {
                      setState(() {
                        _selectedDurationSeconds = duration;
                        _currentStartupMode = _StartupMode.fromDuration(duration);
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isStarting)
              Text(
                'Đang khởi động nhanh (${_currentStartupMode.label})',
                key: const Key('session-start-loading'),
              ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('session-start-button'),
              onPressed: _isStarting ? null : _startSession,
              child: const Text('Bắt đầu'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startSession() async {
    if (_isStarting) {
      return;
    }

    final startupMode = _StartupMode.fromDuration(_selectedDurationSeconds);
    setState(() {
      _isStarting = true;
      _currentStartupMode = startupMode;
    });

    final runtime = const SessionRuntime();
    final event = runtime.startSession(
      sessionRoute: widget.args.sessionRoute,
      manualCheckin: widget.args.manualCheckin,
      sessionDurationSeconds: _selectedDurationSeconds,
      startupMode: startupMode.label,
    );
    final timerState = SessionTimerState.fromStartEvent(
      event.toJson(),
      hasMicrophone: !widget.args.simulateNoMicrophone,
      noiseConfidence: widget.args.simulateLowConfidence ? 0.2 : null,
    );

    await Future.delayed(startupMode.startupDelay);

    if (!mounted) {
      return;
    }

    await Navigator.of(context).pushNamed(
      '/session/active',
      arguments: SessionActiveArgs(
        startEvent: event,
        timerState: timerState,
      ),
    );
  }

  String _durationChipKey(int duration) {
    switch (duration) {
      case 20:
        return 'micro-20s';
      case 45:
        return 'micro-45s';
      case 90:
        return 'micro-90s';
      case 180:
        return 'micro-3m';
      default:
        return 'micro-${duration}s';
    }
  }

  String _durationChipLabel(int duration) {
    switch (duration) {
      case 180:
        return '3m';
      default:
        return '${duration}s';
    }
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
