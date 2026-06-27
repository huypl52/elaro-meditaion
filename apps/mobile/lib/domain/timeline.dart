const String manualCheckinTimelineKey = 'manual_checkin';
const String sessionDurationTimelineKey = 'duration_seconds';
const String startupModeTimelineKey = 'startup_mode';

enum SessionTimelineEventType {
  sessionStart('session_start'),
  sosInterrupt('sos_interrupt'),
  sosTimeoutExit('sos_timeout_exit');

  const SessionTimelineEventType(this.value);

  final String value;
}

class SessionTimelineEvent {
  const SessionTimelineEvent({
    required this.type,
    required this.at,
    required this.payload,
  });

  final SessionTimelineEventType type;
  final DateTime at;
  final Map<String, Object?> payload;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'type': type.value,
      'at': at.toUtc().toIso8601String(),
      ...payload,
    };
  }

  factory SessionTimelineEvent.fromJson(Map<String, Object?> json) {
    final type = SessionTimelineEventType.values.cast<SessionTimelineEventType?>().firstWhere(
          (event) => event?.value == json['type'],
          orElse: () => null,
        ) ??
        SessionTimelineEventType.sosInterrupt;

    final rawAt = json['at'];
    final at = rawAt is String ? DateTime.parse(rawAt) : DateTime.fromMillisecondsSinceEpoch(0).toUtc();

    return SessionTimelineEvent(
      type: type,
      at: at,
      payload: Map<String, Object?>.from(json)..remove('type')..remove('at'),
    );
  }
}

class SessionStartEvent {
  const SessionStartEvent({
    required this.sessionRoute,
    required this.createdAt,
    required this.manualCheckin,
    required this.payload,
  });

  final String sessionRoute;
  final DateTime createdAt;
  final String? manualCheckin;
  final Map<String, Object?> payload;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'session_route': sessionRoute,
      'created_at': createdAt.toIso8601String(),
      manualCheckinTimelineKey: manualCheckin,
      ...payload,
    };
  }

  factory SessionStartEvent.fromJson(Map<String, Object?> json) {
    final createdRaw = json['created_at'];
    final createdAt = createdRaw is String
        ? DateTime.parse(createdRaw)
        : DateTime.fromMillisecondsSinceEpoch(0).toUtc();
    return SessionStartEvent(
      sessionRoute: json['session_route'] as String? ?? '',
      createdAt: createdAt,
      manualCheckin: json[manualCheckinTimelineKey] as String?,
      payload: Map<String, Object?>.from(json)..removeWhere((key, _) => [
            'session_route',
            'created_at',
            manualCheckinTimelineKey,
          ].contains(key)),
    );
  }
}
