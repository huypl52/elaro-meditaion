import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:elaro_mobile/domain/reflection.dart';
import 'package:elaro_mobile/runtime/app_config.dart';
import 'package:elaro_mobile/runtime/dev_gate.dart';
import 'package:elaro_mobile/runtime/microphone_permission_runtime.dart';
import 'package:elaro_mobile/runtime/reflection_runtime.dart';
import 'package:elaro_mobile/runtime/session.dart';

import '../../components/breathing/breathing.dart';
import '../../components/calm_feature_scaffold.dart';
import '../../components/cta.dart';
import '../../components/distress_boundary.dart';
import '../../components/section_card.dart';
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
    return durationSeconds <= 90
        ? _StartupMode.microFast
        : _StartupMode.standard;
  }
}

class EnvironmentalContextSnapshot {
  const EnvironmentalContextSnapshot({
    required this.contextTag,
    required this.confidence,
    this.hasPermission = true,
    this.relativeNoiseLevel = 0,
    this.soundClassification,
  });

  static const double confidenceThreshold = 0.6;
  static const double noisyThreshold = 0.6;

  final String contextTag;
  final double confidence;
  final bool hasPermission;
  final double relativeNoiseLevel;
  final String? soundClassification;

  bool get isConfident => hasPermission && confidence >= confidenceThreshold;
  bool get shouldSuggestSoundscape => isConfident && relativeNoiseLevel >= noisyThreshold;

  String get tagLabel {
    switch (contextTag) {
      case 'urban-vibe':
        return 'Urban Vibe';
      case 'absolute-silence':
        return 'Absolute Silence';
      case 'nature':
        return 'Nature';
      case 'white-noise':
        return 'White noise';
      default:
        return contextTag;
    }
  }

  Map<String, Object?> toSummaryJson() {
    return <String, Object?>{
      'context_tag': contextTag,
      'confidence_band': confidence >= 0.8 ? 'high' : 'medium',
      'noise_band': relativeNoiseLevel >= noisyThreshold ? 'elevated' : 'settled',
    };
  }

  Map<String, Object?> toStartPayloadJson() {
    return <String, Object?>{
      'context_tag': contextTag,
      'confidence': confidence,
      'has_permission': hasPermission,
      'relative_noise_level': relativeNoiseLevel,
      if (soundClassification != null)
        'sound_classification': soundClassification,
    };
  }

  static EnvironmentalContextSnapshot? fromDynamic(Object? value) {
    if (value is EnvironmentalContextSnapshot) {
      return value;
    }
    if (value is! Map) {
      return null;
    }

    final tag = value['contextTag'] ?? value['context_tag'];
    final confidence = _readDouble(value['confidence']);
    if (tag is! String || tag.isEmpty || confidence == null) {
      return null;
    }

    return EnvironmentalContextSnapshot(
      contextTag: tag,
      confidence: confidence,
      hasPermission: value['hasPermission'] as bool? ?? value['has_permission'] as bool? ?? true,
      relativeNoiseLevel: _readDouble(value['relativeNoiseLevel'] ?? value['relative_noise_level']) ?? 0,
      soundClassification: value['soundClassification'] as String? ?? value['sound_classification'] as String?,
    );
  }

  static double? _readDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }
}

class SessionStartArgs {
  static const List<int> microSessionDurations = <int>[20, 45, 90, 180];
  static const int defaultDurationSeconds = 180;

  const SessionStartArgs({
    required this.sessionRoute,
    required this.manualCheckin,
    this.hasMicrophone,
    this.simulateNoMicrophone = false,
    this.simulateLowConfidence = false,
    this.sessionDurationSeconds = defaultDurationSeconds,
    this.environmentalContext,
  });

  final String sessionRoute;
  final CheckinState? manualCheckin;
  final bool? hasMicrophone;
  final bool simulateNoMicrophone;
  final bool simulateLowConfidence;
  final int sessionDurationSeconds;
  final EnvironmentalContextSnapshot? environmentalContext;

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
        sessionRoute:
            args['sessionRoute'] as String? ?? '/session/short-breath',
        manualCheckin: CheckinState.fromName(args['manualCheckin'] as String?),
        hasMicrophone: args['hasMicrophone'] as bool?,
        simulateNoMicrophone: args['simulateNoMicrophone'] as bool? ?? false,
        simulateLowConfidence: args['simulateLowConfidence'] as bool? ?? false,
        sessionDurationSeconds: parsedDuration,
        environmentalContext:
            EnvironmentalContextSnapshot.fromDynamic(args['environmentalContext']),
      );
    }

    if (args is String && args.isNotEmpty) {
      return SessionStartArgs(sessionRoute: args, manualCheckin: null);
    }

    return const SessionStartArgs(
        sessionRoute: '/session/short-breath', manualCheckin: null);
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

class SessionReEntryArgs {
  const SessionReEntryArgs({
    required this.sessionId,
    required this.sessionRoute,
    this.manualCheckin,
    this.hasMicrophone = true,
  });

  final String sessionId;
  final String sessionRoute;
  final CheckinState? manualCheckin;
  final bool hasMicrophone;

  factory SessionReEntryArgs.fromDynamic(Object? args,
      {required String fallbackSessionRoute}) {
    if (args is SessionReEntryArgs) {
      return args;
    }

    if (args is Map) {
      return SessionReEntryArgs(
        sessionId: args['sessionId'] as String? ?? '',
        sessionRoute: args['sessionRoute'] as String? ?? fallbackSessionRoute,
        manualCheckin: CheckinState.fromName(args['manualCheckin'] as String?),
        hasMicrophone: args['hasMicrophone'] as bool? ?? true,
      );
    }

    return SessionReEntryArgs(
      sessionId: '',
      sessionRoute: fallbackSessionRoute,
      manualCheckin: null,
      hasMicrophone: true,
    );
  }
}

class SessionReflectionArgs {
  const SessionReflectionArgs({
    required this.sessionId,
    required this.sessionRoute,
    this.healthPermissionGranted = false,
    this.bio,
    this.environmentalContext,
    this.aiInsightOptIn = false,
    this.aiProviderAvailable = true,
  });

  final String sessionId;
  final String sessionRoute;
  final bool healthPermissionGranted;
  final _BiofeedbackSnapshot? bio;
  final EnvironmentalContextSnapshot? environmentalContext;
  final bool aiInsightOptIn;
  final bool aiProviderAvailable;

  factory SessionReflectionArgs.fromDynamic(Object? args,
      {required String fallbackSessionRoute}) {
    if (args is SessionReflectionArgs) {
      return args;
    }

    if (args is Map) {
      return SessionReflectionArgs(
        sessionId: args['sessionId'] as String? ?? '',
        sessionRoute: args['sessionRoute'] as String? ?? fallbackSessionRoute,
        healthPermissionGranted:
            args['healthPermissionGranted'] as bool? ?? false,
        bio: _BiofeedbackSnapshot.fromDynamic(args['bio']),
        environmentalContext:
            EnvironmentalContextSnapshot.fromDynamic(args['environmentalContext']),
        aiInsightOptIn: args['aiInsightOptIn'] as bool? ?? false,
        aiProviderAvailable: args['aiProviderAvailable'] as bool? ?? true,
      );
    }

    return SessionReflectionArgs(
      sessionId: '',
      sessionRoute: fallbackSessionRoute,
    );
  }
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
  bool _showSoundscapeSuggestion = true;
  final MicrophonePermissionRuntime _microphonePermissionRuntime =
      MicrophonePermissionRuntime.instance;
  final EnvironmentalContextRuntime _environmentalContextRuntime =
      EnvironmentalContextRuntime.instance;
  _StartupMode _currentStartupMode = _StartupMode.standard;
  EnvironmentalContextSnapshot? _environmentalContext;
  bool _hasMicrophone = true;

  @override
  void initState() {
    super.initState();
    _selectedDurationSeconds = widget.args.sessionDurationSeconds;
    _currentStartupMode = _StartupMode.fromDuration(_selectedDurationSeconds);
    _hasMicrophone = !(widget.args.simulateNoMicrophone) &&
        (widget.args.hasMicrophone ?? true);
    _environmentalContext = widget.args.environmentalContext;
    _hydrateEnvironmentalContext();
  }

  Future<void> _hydrateEnvironmentalContext() async {
    final hasMicrophone = widget.args.simulateNoMicrophone
        ? false
        : widget.args.hasMicrophone ??
            await _microphonePermissionRuntime.preflight();
    final sampled = _environmentalContext ??
        _sampleEnvironmentalContext(hasMicrophone: hasMicrophone);
    if (!mounted) {
      return;
    }
    setState(() {
      _hasMicrophone = hasMicrophone;
      _environmentalContext = sampled;
    });
  }

  EnvironmentalContextSnapshot? _sampleEnvironmentalContext({
    required bool hasMicrophone,
  }) {
    final sampled = _environmentalContextRuntime.sample(
      hasMicrophone: hasMicrophone,
      lowConfidence: widget.args.simulateLowConfidence,
      manualCheckin: widget.args.manualCheckin,
    );
    if (sampled == null) {
      return null;
    }
    return EnvironmentalContextSnapshot(
      contextTag: sampled.contextTag,
      confidence: sampled.confidence,
      hasPermission: hasMicrophone,
      relativeNoiseLevel: sampled.relativeNoiseLevel ==
              EnvironmentalNoiseLevel.high
          ? 0.9
          : sampled.relativeNoiseLevel == EnvironmentalNoiseLevel.medium
              ? 0.55
              : 0.2,
      soundClassification: sampled.classification,
    );
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
                        _currentStartupMode =
                            _StartupMode.fromDuration(duration);
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
            const SizedBox(height: 16),
            _buildEnvironmentalContextSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentalContextSection(BuildContext context) {
    final environmentalContext = _environmentalContext;
    final manualFallback =
        'manual-${(widget.args.manualCheckin ?? CheckinState.calm).value}';

    if (environmentalContext == null || !environmentalContext.isConfident) {
      return SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bối cảnh môi trường',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Context thủ công: $manualFallback',
              key: const Key('session-environmental-manual-context'),
            ),
            const SizedBox(height: 4),
            const Text('độ tin cậy thấp'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bối cảnh môi trường',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Chip(
                key: const Key('session-environmental-context-tag'),
                label: Text(environmentalContext.tagLabel),
              ),
              const SizedBox(height: 4),
              const Text('Phân loại on-device, không upload raw audio.'),
            ],
          ),
        ),
        if (environmentalContext.shouldSuggestSoundscape &&
            _showSoundscapeSuggestion) ...[
          const SizedBox(height: 12),
          Card(
            key: const Key('session-soundscape-suggestion-card'),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Không gian có vẻ hơi nhiều chuyển động.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Bạn muốn thêm tiếng mưa nhẹ để dễ ở lại với hơi thở hơn không?',
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      key: const Key('session-soundscape-dismiss'),
                      onPressed: () {
                        setState(() {
                          _showSoundscapeSuggestion = false;
                        });
                      },
                      child: const Text('Để sau'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (DevGate.enabled && environmentalContext.soundClassification != null)
          DevSection(
            child: Text(
              'DEV • environmental classification: ${environmentalContext.soundClassification}',
            ),
          ),
      ],
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

    final hasMicrophone = widget.args.simulateNoMicrophone
        ? false
        : widget.args.hasMicrophone ?? _hasMicrophone;
    final environmentalContext =
        _environmentalContext ?? _sampleEnvironmentalContext(hasMicrophone: hasMicrophone);

    final runtime = const SessionRuntime();
    final event = runtime.startSession(
      sessionRoute: widget.args.sessionRoute,
      manualCheckin: widget.args.manualCheckin,
      sessionDurationSeconds: _selectedDurationSeconds,
      startupMode: startupMode.label,
      environmentalContext: environmentalContext,
    );
    final timerState = SessionTimerState.fromStartEvent(
      event.toJson(),
      hasMicrophone: hasMicrophone,
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

class _SessionActiveScreenState extends State<SessionActiveScreen>
    with WidgetsBindingObserver {
  static const int _breathingPhaseSeconds = 4;
  static const Duration _tickInterval = Duration(seconds: 1);

  final SessionRuntime _runtime = const SessionRuntime();
  final MicrophonePermissionRuntime _microphonePermissionRuntime =
      MicrophonePermissionRuntime.instance;

  late final String _sessionId;
  late final int _sessionDurationSeconds;
  late SessionTimerState _timerState;

  int _elapsedSeconds = 0;
  bool _isPaused = false;
  bool _isComplete = false;
  bool _showRecoveryCard = false;
  bool _showSessionPostNudge = true;
  bool _showEnrichmentDeniedMessage = false;

  StreamSubscription<bool>? _microphonePermissionSubscription;

  Timer? _ticker;
  DateTime? _lastTick;

  late final List<int> _bellCues;
  final Set<int> _firedBells = <int>{};
  late int _lastBreathingPhaseIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _sessionId = widget.args.startEvent.createdAt.toUtc().toIso8601String();
    _sessionDurationSeconds = widget.args.timerState.sessionDurationSeconds;
    _timerState = widget.args.timerState;
    _showEnrichmentDeniedMessage = !_timerState.hasMicrophone;
    _elapsedSeconds = _timerState.elapsedSeconds;
    _isPaused = _timerState.isPaused;
    _isComplete = _elapsedSeconds >= _sessionDurationSeconds;
    _bellCues = resolveBellCues(_sessionDurationSeconds);

    final recovered = _runtime.consumeSessionRecovery(sessionId: _sessionId);
    if (recovered != null && recovered.elapsedSeconds > _elapsedSeconds) {
      _elapsedSeconds = recovered.elapsedSeconds;
      _isPaused = recovered.isPaused;
      _showRecoveryCard = true;
      _runtime.recordRecovery(
          sessionId: _sessionId,
          elapsedSeconds: _elapsedSeconds,
          isPaused: _isPaused);
    }

    _lastBreathingPhaseIndex = _breathingPhaseIndex(_elapsedSeconds);
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

    _microphonePermissionRuntime.preflight();
    _microphonePermissionSubscription = _microphonePermissionRuntime
        .permissionStateStream
        .listen(_handleMicrophonePermissionState);

    _persistState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) {
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
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
    _microphonePermissionSubscription?.cancel();
    _ticker?.cancel();
    _persistState();
    super.dispose();
  }

  void _handleMicrophonePermissionState(bool hasPermission) {
    if (!mounted || _isComplete || hasPermission) {
      return;
    }

    _onDropEnrichment();
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
    _runtime.recordRecovery(
        sessionId: _sessionId,
        elapsedSeconds: _elapsedSeconds,
        isPaused: _isPaused);
    _persistState();

    if (!_isPaused && _elapsedSeconds < _sessionDurationSeconds) {
      _startTicker();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final sourceLabel =
        _timerState.hasMicrophone && !_timerState.usingManualContext
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
              label: reduceMotion
                  ? 'Hiển thị bằng text để an toàn chuyển động'
                  : null,
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
            if (_timerState.usingManualContext)
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Context thủ công: ${_timerState.noiseContextLabel}'),
                      const SizedBox(height: 4),
                      const Text('độ tin cậy thấp'),
                      if (_showEnrichmentDeniedMessage) ...[
                        const SizedBox(height: 4),
                        const Text('Enrichment: bỏ qua (thiếu quyền mic)'),
                      ],
                    ],
                  ),
                ),
              ),
            if (_timerState.usingManualContext) const SizedBox(height: 12),
            if (_showRecoveryCard) _buildRecoveryChoicesCard(context),
            if (_showRecoveryCard) const SizedBox(height: 12),
            if (_isComplete) ...[
              _buildActiveReentryCard(),
              const SizedBox(height: 12),
              _buildSessionActiveMindfulNudge(context),
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
            if (!_isComplete) ...[
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
            ],
            const SizedBox(height: 16),
            if (DevGate.enabled)
              DevSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Session telemetry',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                        'mode: ${_isComplete ? 'complete' : _isPaused ? 'paused' : 'running'}'),
                    Text('offline: ${!_timerState.hasMicrophone}'),
                    Text('source: $sourceLabel'),
                    Text('elapsed: $_elapsedSeconds'),
                    Text(
                      nextBell < 0
                          ? 'bell status: completed'
                          : 'bell status: next in ${nextBell - _elapsedSeconds}s',
                    ),
                    Text(
                        'noise confidence: ${_timerState.noiseConfidence ?? 'n/a'}'),
                    Text('manual_checkin: ${_timerState.manualContext?.value}'),
                    Text('mic toggle: ${_timerState.hasMicrophone}'),
                    Text(
                        'runtime-event label: ${_runtime.latestSessionEventLabel(sessionId: _sessionId)}'),
                    if (_timerState.usingManualContext)
                      Text(
                          'noise_context_label: ${_timerState.noiseContextLabel}'),
                    if (_timerState.noiseConfidence != null)
                      Text('noise_context: ${_timerState.noiseContextLabel}'),
                    TextButton(
                      key: const Key('session-noise-confidence-toggle'),
                      onPressed: _onDropEnrichment,
                      child: const Text('session-noise-confidence-toggle'),
                    ),
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

  Widget _buildActiveReentryCard() {
    return _buildReentryCard(
      context: context,
      onStop: _onSessionReentryStop,
      onRepeat: _onSessionReentryRepeat,
      onFollowup: _onSessionReentryFollowup,
    );
  }

  Widget _buildRecoveryChoicesCard(BuildContext context) {
    return Card(
      key: const Key('session-recovery-card'),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phiên trước đó đã dừng giữa chừng; tiếp tục để giữ đúng mốc nhịp.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('session-recovery-resume'),
              onPressed: _onRecoveryResume,
              child: const Text('Tiếp tục'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('session-recovery-close'),
              onPressed: _onRecoveryClose,
              child: const Text('Kết thúc nhẹ'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('session-recovery-new'),
              onPressed: _onRecoveryNew,
              child: const Text('Phiên mới'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionActiveMindfulNudge(BuildContext context) {
    if (!_showSessionPostNudge) {
      return const SizedBox.shrink();
    }

    return Dismissible(
      key: const Key('session-active-mindful-nudge-card'),
      onDismissed: (_) {
        setState(() {
          _showSessionPostNudge = false;
        });
      },
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nhắc nhẹ tiếp theo',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(
                'Nếu bạn muốn giữ nhịp nhẹ, có thể chọn một phiên ngắn nữa.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: const Key('session-active-mindful-nudge-skip'),
                  onPressed: () {
                    setState(() {
                      _showSessionPostNudge = false;
                    });
                  },
                  child: const Text('Bỏ qua hôm nay'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canUseHaptics(bool reduceMotion) {
    return !reduceMotion && _timerState.hasMicrophone;
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

    final int nextElapsed =
        (_elapsedSeconds + delta).clamp(0, _sessionDurationSeconds);
    if (nextElapsed == _elapsedSeconds) {
      return;
    }

    setState(() {
      _elapsedSeconds = nextElapsed;
      _persistState();
    });

    _syncBells();
    _syncBreathingCue();

    if (_elapsedSeconds >= _sessionDurationSeconds) {
      _complete();
    }
  }

  void _syncBells() {
    for (final cue in _bellCues) {
      if (cue <= _elapsedSeconds && !_firedBells.contains(cue)) {
        _firedBells.add(cue);
        final reduceMotion =
            MediaQuery.maybeOf(context)?.disableAnimations ?? false;
        if (_canUseHaptics(reduceMotion)) {
          HapticFeedback.selectionClick();
        }
        _runtime.recordBell(
            sessionId: _sessionId, elapsedSeconds: _elapsedSeconds, cue: cue);
      }
    }
  }

  void _syncBreathingCue() {
    final phaseIndex = _breathingPhaseIndex(_elapsedSeconds);
    if (phaseIndex == _lastBreathingPhaseIndex) {
      return;
    }

    _lastBreathingPhaseIndex = phaseIndex;
    AccessibilityRuntime.fireHapticCue(
      context,
      HapticFeedbackType.light,
    );
  }

  int _breathingPhaseIndex(int elapsedSeconds) {
    return (elapsedSeconds ~/ _breathingPhaseSeconds) % 4;
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

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
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

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
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

  void _onDropEnrichment() {
    final droppedTimerState = _runtime.dropEnrichment(timerState: _timerState);
    if (droppedTimerState == _timerState) {
      return;
    }

    setState(() {
      _timerState = droppedTimerState;
      _showRecoveryCard = true;
      _showEnrichmentDeniedMessage = true;
    });
    _persistState();
  }

  void _onRecoveryResume() {
    if (_isComplete) {
      return;
    }

    setState(() {
      _showRecoveryCard = false;
    });

    if (_isPaused) {
      _onResume();
      return;
    }

    if (_ticker == null) {
      _startTicker();
    }

    _persistState();
  }

  void _onRecoveryClose() {
    _goHome();
  }

  void _onRecoveryNew() {
    Navigator.of(context).pushNamed(
      '/session/start',
      arguments: SessionStartArgs(
        sessionRoute: widget.args.startEvent.sessionRoute,
        manualCheckin: _timerState.manualContext,
        hasMicrophone: _microphonePermissionRuntime.hasMicrophone,
        simulateLowConfidence: _timerState.isLowConfidence,
      ),
    );
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

  void _onSessionReentryStop() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }

  void _onSessionReentryRepeat() {
    Navigator.of(context).pushNamed(
      '/session/start',
      arguments: SessionStartArgs(
        sessionRoute: widget.args.startEvent.sessionRoute,
        manualCheckin: _timerState.manualContext,
        hasMicrophone: _microphonePermissionRuntime.hasMicrophone,
        simulateLowConfidence: _timerState.isLowConfidence,
      ),
    );
  }

  void _onSessionReentryFollowup() {
    final encodedSessionId = Uri.encodeComponent(_sessionId);
    Navigator.of(context).pushNamed(
      '/session/$encodedSessionId/reflection',
      arguments: SessionReflectionArgs(
        sessionId: _sessionId,
        sessionRoute: widget.args.startEvent.sessionRoute,
      ),
    );
  }

  void _complete() {
    if (_isComplete) {
      return;
    }

    _isComplete = true;
    _ticker?.cancel();
    _ticker = null;

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_canUseHaptics(reduceMotion)) {
      HapticFeedback.mediumImpact();
    }

    _runtime.recordComplete(
        sessionId: _sessionId, elapsedSeconds: _elapsedSeconds);
    _runtime.clearSessionRecovery(_sessionId);
    _persistState();
    setState(() {
      _showRecoveryCard = false;
    });
  }

  void _goHome() {
    _ticker?.cancel();
    _runtime.clearSessionRecovery(_sessionId);
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
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
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_canUseHaptics(reduceMotion)) {
      HapticFeedback.mediumImpact();
    }
  }

  bool _mountedOrActive() {
    return mounted && !_isComplete && !_isPaused;
  }
}

Widget _buildReentryCard({
  required BuildContext context,
  required VoidCallback onStop,
  required VoidCallback onRepeat,
  required VoidCallback onFollowup,
}) {
  return Card(
    key: const Key('session-reentry-card'),
    color: Theme.of(context).colorScheme.surfaceContainerLowest,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kết thúc nhẹ nhàng',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Re-entry sau phiên',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          const Text(
            'Lời nhắc nhẹ: thở chậm 1 nhịp rồi chọn bước kế tiếp.',
            style: TextStyle(height: 1.3),
          ),
          const SizedBox(height: 12),
          TertiaryStackCTA(
            onStop: onStop,
            onRepeat: onRepeat,
            onFollowup: onFollowup,
          ),
        ],
      ),
    ),
  );
}

class TertiaryStackCTA extends StatelessWidget {
  const TertiaryStackCTA({
    super.key,
    required this.onStop,
    required this.onRepeat,
    required this.onFollowup,
  });

  final VoidCallback onStop;
  final VoidCallback onRepeat;
  final VoidCallback onFollowup;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton(
          key: const Key('session-reentry-stop'),
          onPressed: onStop,
          child: const Text('Dừng & về Home'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          key: const Key('session-reentry-repeat'),
          onPressed: onRepeat,
          child: const Text('Lặp lại'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          key: const Key('session-reentry-followup'),
          onPressed: onFollowup,
          child: const Text('Phản chiếu phiên'),
        ),
      ],
    );
  }
}

class SessionReEntryScreen extends StatelessWidget {
  const SessionReEntryScreen({
    required this.args,
  });

  final SessionReEntryArgs args;

  @override
  Widget build(BuildContext context) {
    final sessionId = args.sessionId.isEmpty ? '' : args.sessionId;
    final micPermissionRuntime = MicrophonePermissionRuntime.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Re-entry')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _buildReentryCard(
          context: context,
          onStop: () => Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (Route<dynamic> route) => false,
          ),
          onRepeat: () => Navigator.of(context).pushNamed(
            '/session/start',
            arguments: SessionStartArgs(
              sessionRoute: args.sessionRoute,
              manualCheckin: args.manualCheckin,
              hasMicrophone: micPermissionRuntime.hasMicrophone,
            ),
          ),
          onFollowup: () {
            final encodedSessionId = Uri.encodeComponent(sessionId);
            Navigator.of(context).pushNamed(
              '/session/$encodedSessionId/reflection',
              arguments: SessionReflectionArgs(
                sessionId: args.sessionId,
                sessionRoute: args.sessionRoute,
              ),
            );
          },
        ),
      ),
    );
  }
}

class SessionReflectionScreen extends StatelessWidget {
  const SessionReflectionScreen({
    required this.args,
  });

  final SessionReflectionArgs args;

  @override
  Widget build(BuildContext context) {
    final trend = _SessionReflectionTrend.fromTimeline(
      sessionId: args.sessionId,
      timeline: const SessionRuntime().timeline,
    );

    return CalmFeatureScaffold(
      title: const Text('Phản hồi phiên'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sau phiên',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Phản hồi cảm nhận nhẹ nhàng',
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w700, height: 1.1),
            ),
            const SizedBox(height: 24),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Xu hướng phiên',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trend.copy,
                    key: const Key('session-reflection-trend'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SectionCard(
              child: Text(
                'Tổng kết nhẹ: không đưa ra điểm số, không so sánh…',
                key: Key('session-reflection-no-pressure'),
              ),
            ),
            const SizedBox(height: 16),
            DistressBoundary(
              key: const Key('reflection-distress-boundary'),
              onAction: () => _openSupportResourcesSheet(context),
              child: const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            _BiofeedbackReflectionBlock(
              healthPermissionGranted: args.healthPermissionGranted,
              bio: args.bio,
            ),
            const SizedBox(height: 16),
            _ReflectionDashboardBlock(
              args: args,
              trend: trend,
            ),
            const SizedBox(height: 16),
            Text('Phiên ID: ${args.sessionId}'),
            const SizedBox(height: 16),
            PrimaryCTA(
              buttonKey: const Key('session-reflection-return'),
              label: 'Quay về Home',
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home', (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openSupportResourcesSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const SupportResourcesSheet(),
    );
  }
}

class _SessionReflectionTrend {
  const _SessionReflectionTrend(this.copy);

  final String copy;

  factory _SessionReflectionTrend.fromTimeline({
    required String sessionId,
    required List<SessionTimelineEvent> timeline,
  }) {
    final event = timeline.cast<SessionTimelineEvent?>().lastWhere(
      (candidate) {
        if (candidate == null ||
            candidate.type != SessionTimelineEventType.sessionComplete) {
          return false;
        }
        return candidate.payload[sessionIdTimelineKey] == sessionId;
      },
      orElse: () => null,
    );

    final rawElapsed = event?.payload[elapsedSecondsTimelineKey];
    final elapsedSeconds = switch (rawElapsed) {
      int() => rawElapsed,
      num() => rawElapsed.toInt(),
      _ => null,
    };

    if (elapsedSeconds == null || elapsedSeconds <= 0) {
      return const _SessionReflectionTrend(
        'Phiên này chưa có đủ dấu mốc, hãy xem đây như một ghi chú nhẹ về cảm nhận hiện tại.',
      );
    }

    if (elapsedSeconds <= 45) {
      return const _SessionReflectionTrend(
        'Bạn đã chạm một khoảng dừng ngắn và đủ để nhận lại nhịp thở.',
      );
    }

    if (elapsedSeconds <= 90) {
      return const _SessionReflectionTrend(
        'Bạn đã duy trì sự tĩnh tại ở một chu kỳ tương đối ổn định.',
      );
    }

    return const _SessionReflectionTrend(
      'Bạn đã ở lại lâu hơn với nhịp của mình, theo cách không cần đo đếm.',
    );
  }
}


class _BiofeedbackReflectionBlock extends StatelessWidget {
  const _BiofeedbackReflectionBlock({
    required this.healthPermissionGranted,
    required this.bio,
  });

  final bool healthPermissionGranted;
  final _BiofeedbackSnapshot? bio;

  @override
  Widget build(BuildContext context) {
    final snapshot = bio;

    if (!healthPermissionGranted || snapshot == null) {
      return const SectionCard(
        child: Text(
          'Lúc này dữ liệu sinh trắc chưa sẵn sàng, nên phần phản hồi giữ ở bản cơ bản và quay về cảm nhận của bạn.',
          key: Key('session-reflection-biofeedback-fallback'),
        ),
      );
    }

    if (!snapshot.highConfidence) {
      return const SectionCard(
        child: Text(
          'Tín hiệu sinh trắc lúc này chưa đủ rõ; hãy quay lại với cảm nhận của bạn, không cần đánh giá phiên này.',
          key: Key('session-reflection-biofeedback-low'),
        ),
      );
    }

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phản hồi nâng cao từ tín hiệu sinh trắc',
            key: Key('session-reflection-biofeedback-title'),
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhịp tim ${snapshot.heartRateTone}; chuyển động ${snapshot.movementTone}; nhịp hồi phục ${snapshot.hrvDirection}. đây là chiều hướng, không phải chỉ số',
            key: const Key('session-reflection-biofeedback-body'),
          ),
          const SizedBox(height: 12),
          Container(
            key: const Key('session-reflection-relaxation-state'),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.tertiaryContainer,
                  Theme.of(context).colorScheme.secondaryContainer,
                ],
              ),
            ),
            child: const Text(
              'Trạng thái thư giãn: cơ thể đang chuyển dần sang xu hướng dịu hơn.',
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionDashboardBlock extends StatefulWidget {
  const _ReflectionDashboardBlock({
    required this.args,
    required this.trend,
  });

  final SessionReflectionArgs args;
  final _SessionReflectionTrend trend;

  @override
  State<_ReflectionDashboardBlock> createState() =>
      _ReflectionDashboardBlockState();
}

class _ReflectionDashboardBlockState extends State<_ReflectionDashboardBlock> {
  final SessionRuntime _runtime = const SessionRuntime();
  late final Future<ReflectionInsight> _insightFuture = _loadInsight();

  @override
  Widget build(BuildContext context) {
    final environmental = _resolvedEnvironmentalContext();
    final bioSummary = _bioSummary();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          key: const Key('session-reflection-dashboard'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bản đồ phản chiếu phiên',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (environmental == null && bioSummary == null)
                const Text(
                  'Hiện chỉ có dữ liệu nền của phiên này, nên phản hồi giữ ở trạng thái nhẹ và không suy diễn thêm.',
                  key: Key('session-reflection-dashboard-fallback'),
                )
              else ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (environmental != null)
                      Chip(
                        key: const Key('session-reflection-environment-chip'),
                        label: Text('Bối cảnh: ${environmental.tagLabel}'),
                      ),
                    if (bioSummary != null)
                      const Chip(
                        key: Key('session-reflection-bio-chip'),
                        label: Text('Cơ thể: có tín hiệu được phép'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _correlationCopy(environmental: environmental, bioSummary: bioSummary),
                  key: const Key('session-reflection-dashboard-correlation'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<bool>(
          valueListenable: AiConsentRuntime.instance.optedInListenable,
          builder: (context, optedIn, _) {
            if (optedIn) {
              return const SizedBox.shrink();
            }
            return const SectionCard(
              child: Text(
                'AI insight hiện đang tắt. Bạn có thể bật trong Settings; local fallback vẫn tiếp tục dùng được.',
                key: Key('session-reflection-ai-opt-in-copy'),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        FutureBuilder<ReflectionInsight>(
          future: _insightFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SectionCard(
                child: Text(
                  'Đang làm dịu lại bản tóm tắt của phiên...',
                  key: Key('session-reflection-ai-loading'),
                ),
              );
            }

            final insight = snapshot.data ??
                const ReflectionInsight(
                  message:
                      'Phiên này đang được giữ ở bản tóm tắt nội bộ, không cần thêm xử lý nào khác.',
                  source: 'local-fallback',
                );

            return SectionCard(
              key: const Key('session-reflection-ai-message-card'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.fromProvider
                        ? 'Empathetic insight'
                        : 'Empathetic insight · local fallback',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    insight.message,
                    key: const Key('session-reflection-ai-message'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Future<ReflectionInsight> _loadInsight() async {
    final cached = _runtime.latestReflectionInsightForSession(widget.args.sessionId);
    if (cached != null) {
      final message = cached.payload['message'] as String?;
      final source = cached.payload['source'] as String?;
      if (message != null && source != null) {
        return ReflectionInsight(message: message, source: source);
      }
    }

    final summary = ReflectionSummary(
      sessionId: widget.args.sessionId,
      sessionRoute: widget.args.sessionRoute,
      elapsedSeconds: _elapsedSeconds(),
      trendCopy: widget.trend.copy,
      environmentalContext: _toEnvironmentalEvidence(_resolvedEnvironmentalContext()),
      biofeedbackSummary: _bioSummary(),
    );

    final insight = await ReflectionRuntime.instance.buildEmpatheticInsight(summary: summary);
    _runtime.recordReflectionInsight(
      sessionId: widget.args.sessionId,
      message: insight.message,
      source: insight.source,
    );
    if (!insight.fromProvider &&
        AiConsentRuntime.instance.optedIn &&
        AppConfig.hasOpenAiKey) {
      _runtime.recordProviderFallback(
        sessionId: widget.args.sessionId,
        reason: 'provider-unavailable',
      );
    }
    return insight;
  }

  int _elapsedSeconds() {
    final event = _runtime.timeline.cast<SessionTimelineEvent?>().lastWhere(
          (candidate) =>
              candidate?.type == SessionTimelineEventType.sessionComplete &&
              candidate?.payload[sessionIdTimelineKey] == widget.args.sessionId,
          orElse: () => null,
        );
    final rawElapsed = event?.payload[elapsedSecondsTimelineKey];
    return switch (rawElapsed) {
      int() => rawElapsed,
      num() => rawElapsed.toInt(),
      _ => 0,
    };
  }

  EnvironmentalContextSnapshot? _resolvedEnvironmentalContext() {
    final fromArgs = widget.args.environmentalContext;
    if (fromArgs != null) {
      return fromArgs;
    }
    final startEvent = _runtime.latestStartEventForSession(widget.args.sessionId);
    if (startEvent == null) {
      return null;
    }
    return EnvironmentalContextSnapshot.fromDynamic(startEvent.payload);
  }

  EnvironmentalContextEvidence? _toEnvironmentalEvidence(
    EnvironmentalContextSnapshot? snapshot,
  ) {
    if (snapshot == null) {
      return null;
    }
    return EnvironmentalContextEvidence(
      contextTag: snapshot.contextTag,
      classification: snapshot.soundClassification ?? 'steady-breath',
      relativeNoiseLevel: snapshot.relativeNoiseLevel >= EnvironmentalContextSnapshot.noisyThreshold
          ? EnvironmentalNoiseLevel.high
          : snapshot.relativeNoiseLevel > 0.3
              ? EnvironmentalNoiseLevel.medium
              : EnvironmentalNoiseLevel.low,
      confidence: snapshot.confidence,
      soundscapeSuggestion: snapshot.shouldSuggestSoundscape ? 'tiếng mưa nhẹ' : null,
    );
  }

  String? _bioSummary() {
    final snapshot = widget.args.bio;
    if (!widget.args.healthPermissionGranted || snapshot == null) {
      return null;
    }
    if (!snapshot.highConfidence) {
      return null;
    }
    return 'Nhịp tim ${snapshot.heartRateTone}; chuyển động ${snapshot.movementTone}; nhịp hồi phục ${snapshot.hrvDirection}.';
  }

  String _correlationCopy({
    required EnvironmentalContextSnapshot? environmental,
    required String? bioSummary,
  }) {
    if (environmental == null && bioSummary == null) {
      return 'Bản phản chiếu này đang ở mức nền.';
    }
    if (environmental != null && bioSummary != null) {
      return 'Bối cảnh ${environmental.tagLabel.toLowerCase()} và tín hiệu cơ thể đang được đặt cạnh nhau như một xu hướng mềm, không phải bảng điểm.';
    }
    if (environmental != null) {
      return 'Bối cảnh ${environmental.tagLabel.toLowerCase()} đang được giữ như một tín hiệu gợi ý, không phải kết luận.';
    }
    return 'Tín hiệu cơ thể đang được giữ như một chiều hướng dịu để bạn đối chiếu lại với cảm nhận của mình.';
  }
}

class _BiofeedbackSnapshot {
  const _BiofeedbackSnapshot({
    required this.heartRateBpm,
    required this.movementLevel,
    required this.hrvValue,
    required this.confidence,
  });

  final double heartRateBpm;
  final double movementLevel;
  final double hrvValue;
  final double confidence;

  bool get highConfidence => confidence >= 0.6;

  String get heartRateTone {
    if (heartRateBpm <= 70) {
      return 'ổn định';
    }
    if (heartRateBpm <= 90) {
      return 'chưa cao';
    }
    return 'hơi dồn dập';
  }

  String get movementTone {
    if (movementLevel <= 0.2) {
      return 'rất tĩnh';
    }
    if (movementLevel <= 0.6) {
      return 'dịu dịu';
    }
    return 'có dao động nhẹ';
  }

  String get hrvDirection {
    if (hrvValue >= 28) {
      return 'ổn định hơn';
    }
    return 'đang hồi dần';
  }

  static _BiofeedbackSnapshot? fromDynamic(Object? value) {
    if (value is _BiofeedbackSnapshot) {
      return value;
    }
    if (value is! Map) {
      return null;
    }

    final heartRateBpm = _readDouble(value['heartRateBpm']);
    final movementLevel = _readDouble(value['movementLevel']);
    final hrvValue = _readDouble(value['hrvValue']);
    final confidence = _readDouble(value['confidence']);

    if (heartRateBpm == null ||
        movementLevel == null ||
        hrvValue == null ||
        confidence == null) {
      return null;
    }

    return _BiofeedbackSnapshot(
      heartRateBpm: heartRateBpm,
      movementLevel: movementLevel,
      hrvValue: hrvValue,
      confidence: confidence,
    );
  }

  static double? _readDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return null;
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
