import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:elaro_mobile/runtime/dev_gate.dart';
import 'package:elaro_mobile/runtime/session.dart';

import '../../components/breathing/breathing.dart';
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

class SessionActiveScreen extends StatefulWidget {
  const SessionActiveScreen({super.key, required this.args});

  final SessionActiveArgs args;

  @override
  State<SessionActiveScreen> createState() => _SessionActiveScreenState();
}

class _SessionActiveScreenState extends State<SessionActiveScreen> with WidgetsBindingObserver {
  static const int _breathingPhaseSeconds = 4;
  static const Duration _tickInterval = Duration(seconds: 1);

  final SessionRuntime _runtime = const SessionRuntime();

  late final String _sessionId;
  late final int _sessionDurationSeconds;

  int _elapsedSeconds = 0;
  bool _isPaused = false;
  bool _isComplete = false;
  bool _showRecoveryCard = false;

  Timer? _ticker;
  DateTime? _lastTick;

  late final List<int> _bellCues;
  final Set<int> _firedBells = <int>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _sessionId = widget.args.startEvent.createdAt.toUtc().toIso8601String();
    _sessionDurationSeconds = widget.args.timerState.sessionDurationSeconds;
    _elapsedSeconds = widget.args.timerState.elapsedSeconds;
    _isPaused = widget.args.timerState.isPaused;
    _isComplete = _elapsedSeconds >= _sessionDurationSeconds;
    _bellCues = resolveBellCues(_sessionDurationSeconds);

    final recovered = _runtime.consumeSessionRecovery(sessionId: _sessionId);
    if (recovered != null && recovered.elapsedSeconds > _elapsedSeconds) {
      _elapsedSeconds = recovered.elapsedSeconds;
      _isPaused = recovered.isPaused;
      _showRecoveryCard = true;
      _runtime.recordRecovery(sessionId: _sessionId, elapsedSeconds: _elapsedSeconds, isPaused: _isPaused);
    }

    _syncBells();

    if (!_isComplete && !_isPaused) {
      _startTicker();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _emitStartHaptic();
    });
    _persistState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) {
      return;
    }

    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached || state == AppLifecycleState.inactive) {
      _persistState();
      _ticker?.cancel();
      _ticker = null;
      return;
    }

    if (state == AppLifecycleState.resumed && mounted && !_isComplete) {
      _restoreAfterInterruption();
      _startTicker();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _persistState();
    super.dispose();
  }

  void _restoreAfterInterruption() {
    final snapshot = _runtime.consumeSessionRecovery(sessionId: _sessionId);
    if (snapshot == null) {
      return;
    }

    setState(() {
      if (snapshot.elapsedSeconds > _elapsedSeconds) {
        _elapsedSeconds = snapshot.elapsedSeconds;
      }

      _isPaused = snapshot.isPaused;
      _showRecoveryCard = true;
    });
    _runtime.recordRecovery(sessionId: _sessionId, elapsedSeconds: _elapsedSeconds, isPaused: _isPaused);
    _persistState();

    if (!_isPaused && _elapsedSeconds < _sessionDurationSeconds) {
      _startTicker();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final sourceLabel = widget.args.timerState.hasMicrophone && !widget.args.timerState.usingManualContext
        ? 'sensor'
        : 'manual';
    final nextBell = _nextBell;

    return Scaffold(
      appBar: AppBar(title: const Text('Phiên đang chạy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                widget.args.startEvent.sessionRoute,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 16),
            SoftTimer(
              totalSeconds: _sessionDurationSeconds,
              elapsedSeconds: _elapsedSeconds,
              label: reduceMotion ? 'Hiển thị bằng text để an toàn chuyển động' : null,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: ProgressRing(size: 220, progress: _progress),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: BreathingCircle(
                elapsedSeconds: _elapsedSeconds,
                maxSize: 120,
                phaseDuration: const Duration(seconds: _breathingPhaseSeconds),
              ),
            ),
            const SizedBox(height: 12),
            SessionStateLabel(
              isPaused: _isPaused,
              isComplete: _isComplete,
              elapsedSeconds: _elapsedSeconds,
              key: const Key('session-state-label'),
            ),
            const SizedBox(height: 16),
            if (_showRecoveryCard)
              Card(
                key: const Key('session-recovery-card'),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Phiên trước đó đã dừng giữa chừng; tiếp tục để giữ đúng mốc nhịp.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            if (_showRecoveryCard) const SizedBox(height: 12),
            if (_isComplete) ...[
              Text(
                'Phiên đã kết thúc.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
            ] else if (_isPaused) ...[
              GhostTextButton(
                key: const Key('session-resume-btn'),
                onPressed: _onResume,
                label: 'Tiếp tục',
              ),
              const SizedBox(height: 8),
            ] else ...[
              OutlinedButton(
                key: const Key('session-pause-btn'),
                onPressed: _onPause,
                child: const Text('Tạm dừng'),
              ),
            ],
            GhostTextButton(
              onPressed: _onManualExit,
              label: 'Kết thúc sớm',
              key: const Key('session-manual-exit-btn'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('session-return-home'),
              onPressed: _goHome,
              child: const Text('Kết thúc và về Home'),
            ),
            const SizedBox(height: 16),
            if (DevGate.enabled)
              DevSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Session telemetry', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('mode: ${_isComplete ? 'complete' : _isPaused ? 'paused' : 'running'}'),
                    Text('offline: ${!widget.args.timerState.hasMicrophone}'),
                    Text('source: $sourceLabel'),
                    Text('elapsed: $_elapsedSeconds'),
                    Text(
                      nextBell < 0
                          ? 'bell status: completed'
                          : 'bell status: next in ${nextBell - _elapsedSeconds}s',
                    ),
                    Text('noise confidence: ${widget.args.timerState.noiseConfidence ?? 'n/a'}'),
                    Text('manual_checkin: ${widget.args.timerState.manualContext?.value}'),
                    Text('mic toggle: ${widget.args.timerState.hasMicrophone}'),
                    Text('runtime-event label: ${_runtime.latestSessionEventLabel(sessionId: _sessionId)}'),
                    if (widget.args.timerState.usingManualContext)
                      Text('noise_context_label: ${widget.args.timerState.noiseContextLabel}'),
                    if (widget.args.timerState.noiseConfidence != null)
                      Text('noise_context: ${widget.args.timerState.noiseContextLabel}'),
                  ],
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  double get _progress {
    if (_sessionDurationSeconds <= 0) {
      return 0;
    }
    return _elapsedSeconds / _sessionDurationSeconds;
  }

  int get _nextBell {
    for (final cue in _bellCues) {
      if (cue > _elapsedSeconds) {
        return cue;
      }
    }
    return -1;
  }

  bool _canUseHaptics(bool reduceMotion) {
    return !reduceMotion && widget.args.timerState.hasMicrophone;
  }

  void _startTicker() {
    _ticker?.cancel();
    _lastTick = DateTime.now().toUtc();
    _ticker = Timer.periodic(_tickInterval, (_) => _onTick());
  }

  void _onTick() {
    if (!_mountedOrActive()) {
      return;
    }

    final now = DateTime.now().toUtc();
    final reference = _lastTick ?? now;
    final delta = now.difference(reference).inSeconds;
    _lastTick = now;

    if (delta <= 0) {
      return;
    }

    final int nextElapsed = (_elapsedSeconds + delta).clamp(0, _sessionDurationSeconds);
    if (nextElapsed == _elapsedSeconds) {
      return;
    }

    setState(() {
      _elapsedSeconds = nextElapsed;
      _persistState();
    });

    _syncBells();

    if (_elapsedSeconds >= _sessionDurationSeconds) {
      _complete();
    }
  }

  void _syncBells() {
    for (final cue in _bellCues) {
      if (cue <= _elapsedSeconds && !_firedBells.contains(cue)) {
        _firedBells.add(cue);
        final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
        if (_canUseHaptics(reduceMotion)) {
          HapticFeedback.selectionClick();
        }
        _runtime.recordBell(sessionId: _sessionId, elapsedSeconds: _elapsedSeconds, cue: cue);
      }
    }
  }

  void _onPause() {
    if (_isPaused || _isComplete) {
      return;
    }

    setState(() {
      _isPaused = true;
      _ticker?.cancel();
      _ticker = null;
      _persistState();
    });

    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_canUseHaptics(reduceMotion)) {
      HapticFeedback.selectionClick();
    }
    _runtime.recordPause(
      sessionId: _sessionId,
      elapsedSeconds: _elapsedSeconds,
      reason: 'manual',
    );
    _runtime.saveSessionRecovery(
      sessionId: _sessionId,
      sessionDurationSeconds: _sessionDurationSeconds,
      elapsedSeconds: _elapsedSeconds,
      isPaused: true,
    );
  }

  void _onResume() {
    if (!_isPaused || _isComplete) {
      return;
    }

    setState(() {
      _isPaused = false;
      _showRecoveryCard = false;
      _syncBells();
    });

    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_canUseHaptics(reduceMotion)) {
      HapticFeedback.lightImpact();
    }
    _runtime.recordResume(
      sessionId: _sessionId,
      elapsedSeconds: _elapsedSeconds,
      reason: 'resume',
    );
    _runtime.saveSessionRecovery(
      sessionId: _sessionId,
      sessionDurationSeconds: _sessionDurationSeconds,
      elapsedSeconds: _elapsedSeconds,
      isPaused: false,
    );

    _persistState();
    _startTicker();
  }

  void _onManualExit() {
    if (_isComplete) {
      _goHome();
      return;
    }

    _runtime.recordManualExit(
      sessionId: _sessionId,
      elapsedSeconds: _elapsedSeconds,
      reason: 'manual-exit',
    );
    _goHome();
  }

  void _complete() {
    if (_isComplete) {
      return;
    }

    _isComplete = true;
    _ticker?.cancel();
    _ticker = null;

    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_canUseHaptics(reduceMotion)) {
      HapticFeedback.mediumImpact();
    }

    _runtime.recordComplete(sessionId: _sessionId, elapsedSeconds: _elapsedSeconds);
    _runtime.clearSessionRecovery(_sessionId);
    _persistState();
    setState(() {
      _showRecoveryCard = false;
    });
  }

  void _goHome() {
    _ticker?.cancel();
    _runtime.clearSessionRecovery(_sessionId);
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }

  void _persistState() {
    if (_isComplete) {
      _runtime.clearSessionRecovery(_sessionId);
      return;
    }

    _runtime.saveSessionRecovery(
      sessionId: _sessionId,
      sessionDurationSeconds: _sessionDurationSeconds,
      elapsedSeconds: _elapsedSeconds,
      isPaused: _isPaused,
      at: DateTime.now().toUtc(),
    );
  }

  void _emitStartHaptic() {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_canUseHaptics(reduceMotion)) {
      HapticFeedback.mediumImpact();
    }
  }

  bool _mountedOrActive() {
    return mounted && !_isComplete && !_isPaused;
  }
}

List<int> resolveBellCues(int sessionDurationSeconds) {
  if (sessionDurationSeconds <= 20) {
    return const <int>[5, 10, 15];
  }
  if (sessionDurationSeconds <= 45) {
    return const <int>[5, 15, 35];
  }
  if (sessionDurationSeconds <= 90) {
    return const <int>[15, 45, 75];
  }
  return const <int>[45, 90, 135, 175];
}

class GhostTextButton extends StatelessWidget {
  const GhostTextButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
