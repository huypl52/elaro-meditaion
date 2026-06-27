const String manualCheckinTimelineKey = 'manual_checkin';

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
