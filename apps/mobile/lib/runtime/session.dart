import 'package:elaro_mobile/domain/timeline.dart';

import '../features/session/session.dart';

class SessionRuntime {
  static final List<SessionTimelineEvent> _timeline = <SessionTimelineEvent>[];
  static final Map<String, SessionRecoveryState> _recoveryStates = <String, SessionRecoveryState>{};

  const SessionRuntime();

  void resetForTests() {
    _timeline.clear();
    _recoveryStates.clear();
  }

  SessionTimerState dropEnrichment({
    required SessionTimerState timerState,
  }) {
    if (!timerState.hasMicrophone && timerState.noiseConfidence == 0.2) {
      return timerState;
    }

    return SessionTimerState(
      manualContext: timerState.manualContext,
      hasMicrophone: false,
      noiseConfidence: 0.2,
      sessionDurationSeconds: timerState.sessionDurationSeconds,
      elapsedSeconds: timerState.elapsedSeconds,
      isPaused: timerState.isPaused,
    );
  }

  List<SessionTimelineEvent> get timeline => List.unmodifiable(_timeline);

  int get totalSessionCount {
    return _completedSessionEvents.length;
  }

  int get totalSessionDurationSeconds {
    var total = 0;
    for (final event in _completedSessionEvents) {
      final Object? rawElapsed = event.payload[elapsedSecondsTimelineKey];
      final int seconds = switch (rawElapsed) {
        int() => rawElapsed,
        num() => rawElapsed.toInt(),
        _ => 0,
      };
      if (seconds > 0) {
        total += seconds;
      }
    }
    return total;
  }

  SessionStartEvent startSession({
    required String sessionRoute,
    required CheckinState? manualCheckin,
    required int sessionDurationSeconds,
    required String startupMode,
  }) {
    final createdAt = DateTime.now().toUtc();
    final event = SessionStartEvent(
      sessionRoute: sessionRoute,
      createdAt: createdAt,
      manualCheckin: manualCheckin?.value,
      payload: <String, Object?>{
        sessionDurationTimelineKey: sessionDurationSeconds,
        startupModeTimelineKey: startupMode,
        sessionIdTimelineKey: createdAt.toUtc().toIso8601String(),
      },
    );

    _appendTimelineEvent(
      type: SessionTimelineEventType.sessionStart,
      at: createdAt,
      sessionId: createdAt.toIso8601String(),
      elapsedSeconds: 0,
      payload: <String, Object?>{
        'session_route': event.sessionRoute,
        ...event.payload,
      },
    );

    return event;
  }

  void recordPause({
    required String sessionId,
    required int elapsedSeconds,
    DateTime? at,
    String? reason,
  }) {
    _appendTimelineEvent(
      type: SessionTimelineEventType.sessionPause,
      at: at ?? DateTime.now().toUtc(),
      sessionId: sessionId,
      elapsedSeconds: elapsedSeconds,
      payload: _reasonPayload(reason),
    );
  }

  void recordResume({
    required String sessionId,
    required int elapsedSeconds,
    DateTime? at,
    String? reason,
  }) {
    _appendTimelineEvent(
      type: SessionTimelineEventType.sessionResume,
      at: at ?? DateTime.now().toUtc(),
      sessionId: sessionId,
      elapsedSeconds: elapsedSeconds,
      payload: _reasonPayload(reason),
    );
  }

  void recordComplete({
    required String sessionId,
    required int elapsedSeconds,
    DateTime? at,
  }) {
    _appendTimelineEvent(
      type: SessionTimelineEventType.sessionComplete,
      at: at ?? DateTime.now().toUtc(),
      sessionId: sessionId,
      elapsedSeconds: elapsedSeconds,
    );
    clearSessionRecovery(sessionId);
  }

  void recordManualExit({
    required String sessionId,
    required int elapsedSeconds,
    required String reason,
    DateTime? at,
  }) {
    _appendTimelineEvent(
      type: SessionTimelineEventType.sessionManualExit,
      at: at ?? DateTime.now().toUtc(),
      sessionId: sessionId,
      elapsedSeconds: elapsedSeconds,
      payload: _reasonPayload(reason),
    );
    clearSessionRecovery(sessionId);
  }

  void recordBell({
    required String sessionId,
    required int elapsedSeconds,
    required int cue,
  }) {
    _appendTimelineEvent(
      type: SessionTimelineEventType.sessionBell,
      at: DateTime.now().toUtc(),
      sessionId: sessionId,
      elapsedSeconds: elapsedSeconds,
      payload: <String, Object?>{reasonTimelineKey: 'cue-$cue'},
    );
  }

  void recordRecovery({
    required String sessionId,
    required int elapsedSeconds,
    required bool isPaused,
  }) {
    _appendTimelineEvent(
      type: SessionTimelineEventType.sessionRecovery,
      at: DateTime.now().toUtc(),
      sessionId: sessionId,
      elapsedSeconds: elapsedSeconds,
      payload: <String, Object?>{
        'is_paused': isPaused,
      },
    );
  }

  void recordSosInterrupt({
    required String reason,
  }) {
    _appendTimelineEvent(
      type: SessionTimelineEventType.sosInterrupt,
      at: DateTime.now().toUtc(),
      sessionId: 'sos',
      elapsedSeconds: 0,
      payload: <String, Object?>{reasonTimelineKey: reason},
    );
  }

  void recordSosTimeoutExit() {
    _appendTimelineEvent(
      type: SessionTimelineEventType.sosTimeoutExit,
      at: DateTime.now().toUtc(),
      sessionId: 'sos',
      elapsedSeconds: 0,
      payload: const <String, Object?>{},
    );
  }

  void saveSessionRecovery({
    required String sessionId,
    required int sessionDurationSeconds,
    required int elapsedSeconds,
    required bool isPaused,
    DateTime? at,
  }) {
    _recoveryStates[sessionId] = SessionRecoveryState(
      sessionDurationSeconds: sessionDurationSeconds,
      elapsedSeconds: elapsedSeconds,
      isPaused: isPaused,
      recordedAt: at ?? DateTime.now().toUtc(),
    );
  }

  SessionRecoveryState? consumeSessionRecovery({required String sessionId}) {
    final snapshot = _recoveryStates[sessionId];
    if (snapshot == null) {
      return null;
    }
    _recoveryStates.remove(sessionId);
    return snapshot;
  }

  SessionRecoveryState? peekSessionRecovery({required String sessionId}) {
    return _recoveryStates[sessionId];
  }

  void clearSessionRecovery(String sessionId) {
    _recoveryStates.remove(sessionId);
  }

  bool hasSessionRecovery({required String sessionId}) {
    return _recoveryStates.containsKey(sessionId);
  }

  String latestSessionEventLabel({required String sessionId}) {
    final latest = _latestEventForSession(sessionId);
    if (latest == null) {
      return 'none';
    }
    return latest.type.value;
  }

  SessionTimelineEvent? _latestEventForSession(String sessionId) {
    for (final event in _timeline.reversed) {
      if (event.payload[sessionIdTimelineKey] == sessionId) {
        return event;
      }
    }
    return null;
  }

  Iterable<SessionTimelineEvent> get _completedSessionEvents {
    final Map<String, SessionTimelineEvent> latestBySessionId = <String, SessionTimelineEvent>{};
    for (final event in _timeline.reversed) {
      if (event.type != SessionTimelineEventType.sessionComplete) {
        continue;
      }

      final Object? rawSessionId = event.payload[sessionIdTimelineKey];
      if (rawSessionId is! String || rawSessionId.isEmpty) {
        continue;
      }
      latestBySessionId.putIfAbsent(rawSessionId, () => event);
    }

    return latestBySessionId.values;
  }

  void _appendTimelineEvent({
    required SessionTimelineEventType type,
    required String sessionId,
    required int elapsedSeconds,
    required DateTime at,
    Map<String, Object?>? payload,
  }) {
    final effectivePayload = <String, Object?>{
      sessionIdTimelineKey: sessionId,
      elapsedSecondsTimelineKey: elapsedSeconds,
      ...?payload,
    };

    _timeline.add(
      SessionTimelineEvent(
        type: type,
        at: at,
        payload: effectivePayload,
      ),
    );
  }

  Map<String, Object?> _reasonPayload(String? reason) {
    if (reason == null || reason.isEmpty) {
      return const <String, Object?>{};
    }
    return <String, Object?>{reasonTimelineKey: reason};
  }
}

class SessionRecoveryState {
  const SessionRecoveryState({
    required this.sessionDurationSeconds,
    required this.elapsedSeconds,
    required this.isPaused,
    required this.recordedAt,
  });

  final int sessionDurationSeconds;
  final int elapsedSeconds;
  final bool isPaused;
  final DateTime recordedAt;
}

class SessionTimerState {
  const SessionTimerState({
    required this.manualContext,
    required this.hasMicrophone,
    this.noiseConfidence,
    required this.sessionDurationSeconds,
    required this.elapsedSeconds,
    required this.isPaused,
  });

  static const double lowConfidenceThreshold = 0.6;
  final CheckinState? manualContext;
  final bool hasMicrophone;
  final double? noiseConfidence;
  final int sessionDurationSeconds;
  final int elapsedSeconds;
  final bool isPaused;

  bool get isLowConfidence {
    final confidence = noiseConfidence;
    return confidence != null && confidence < lowConfidenceThreshold;
  }

  factory SessionTimerState.fromStartEvent(
    Map<String, Object?> startEvent, {
    required bool hasMicrophone,
    double? noiseConfidence,
    int? elapsedSeconds,
    bool? isPaused,
  }) {
    return SessionTimerState(
      manualContext: CheckinState.fromName(startEvent[manualCheckinTimelineKey] as String?),
      hasMicrophone: hasMicrophone,
      noiseConfidence: noiseConfidence,
      sessionDurationSeconds: startEvent[sessionDurationTimelineKey] as int? ?? SessionStartArgs.defaultDurationSeconds,
      elapsedSeconds: elapsedSeconds ?? 0,
      isPaused: isPaused ?? false,
    );
  }

  bool get usingManualContext {
    if (!hasMicrophone) return true;
    if (noiseConfidence == null) return false;
    return isLowConfidence;
  }

  String get noiseContextLabel {
    if (!hasMicrophone || usingManualContext) {
      final fallback = manualContext ?? CheckinState.calm;
      return 'manual-${fallback.value}';
    }
    return 'sensor-live';
  }

  bool get isExpired => elapsedSeconds >= sessionDurationSeconds;
}
