import 'package:elaro_mobile/domain/timeline.dart';

import '../features/session/session.dart';

class SessionRuntime {
  const SessionRuntime();

  SessionStartEvent startSession({
    required String sessionRoute,
    required CheckinState? manualCheckin,
  }) {
    return SessionStartEvent(
      sessionRoute: sessionRoute,
      createdAt: DateTime.now().toUtc(),
      manualCheckin: manualCheckin?.value,
      payload: const <String, Object?>{},
    );
  }
}

class SessionTimerState {
  const SessionTimerState({
    required this.manualContext,
    required this.hasMicrophone,
    this.noiseConfidence,
  });

  static const double lowConfidenceThreshold = 0.55;
  final CheckinState? manualContext;
  final bool hasMicrophone;
  final double? noiseConfidence;

  factory SessionTimerState.fromStartEvent(
    Map<String, Object?> startEvent, {
    required bool hasMicrophone,
    double? noiseConfidence,
  }) {
    return SessionTimerState(
      manualContext: CheckinState.fromName(startEvent[manualCheckinTimelineKey] as String?),
      hasMicrophone: hasMicrophone,
      noiseConfidence: noiseConfidence,
    );
  }

  bool get usingManualContext {
    if (!hasMicrophone) return true;
    final confidence = noiseConfidence;
    if (confidence == null) return false;
    return confidence < lowConfidenceThreshold;
  }

  String get noiseContextLabel {
    if (!hasMicrophone || usingManualContext) {
      final fallback = manualContext ?? CheckinState.calm;
      return 'manual-${fallback.value}';
    }
    return 'sensor-live';
  }
}
