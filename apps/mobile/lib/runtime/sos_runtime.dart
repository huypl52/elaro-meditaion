import 'package:elaro_mobile/features/session/session.dart';
import 'package:elaro_mobile/runtime/dev_gate.dart';

enum SosMode {
  active,
  calmSafe,
}

class SosModeDecision {
  const SosModeDecision({required this.mode, this.reason});

  final SosMode mode;
  final String? reason;
}

class SosRuntime {
  SosRuntime._();

  static final SosRuntime _instance = SosRuntime._();
  static SosRuntime get instance => _instance;

  DateTime? _lastStartTime;
  String? _lastDecisionReason;

  DateTime? get lastStartTime => _lastStartTime;
  String? get lastDecisionReason => _lastDecisionReason;

  SosModeDecision evaluateMode({
    required DateTime now,
    required SosEntryArgs args,
  }) {
    if (!args.contextAvailable || args.contextSnapshot == null) {
      _lastDecisionReason = 'missing-context';
      return const SosModeDecision(mode: SosMode.calmSafe, reason: 'missing-context');
    }

    if (!args.sensorAvailable) {
      _lastDecisionReason = 'missing-sensor';
      return const SosModeDecision(mode: SosMode.calmSafe, reason: 'missing-sensor');
    }

    if (_lastStartTime != null && now.difference(_lastStartTime!).inSeconds < 60) {
      _lastDecisionReason = 'repeated-sos';
      return const SosModeDecision(mode: SosMode.calmSafe, reason: 'repeated-sos');
    }

    if (args.contextSnapshot == CheckinState.overload && _isNight(now)) {
      _lastDecisionReason = 'overload-night';
      return const SosModeDecision(mode: SosMode.calmSafe, reason: 'overload-night');
    }

    _lastDecisionReason = null;
    return const SosModeDecision(mode: SosMode.active);
  }

  void registerEntry(DateTime now) {
    _lastStartTime = now;
    _lastDecisionReason = null;
  }

  void resetForTests() {
    _lastStartTime = null;
    _lastDecisionReason = null;
  }

  bool get showTelemetry => DevGate.enabled;

  bool _isNight(DateTime now) {
    return now.hour >= 22 || now.hour < 6;
  }
}

class SosEntryArgs {
  const SosEntryArgs({
    this.contextSnapshot,
    required this.contextAvailable,
    required this.sensorAvailable,
    this.hapticEnabled = true,
  });

  factory SosEntryArgs.fromDynamic(Object? args) {
    if (args is SosEntryArgs) {
      return args;
    }

    if (args is Map) {
      return SosEntryArgs(
        contextAvailable: args['contextAvailable'] as bool? ?? false,
        sensorAvailable: args['sensorAvailable'] as bool? ?? false,
        hapticEnabled: args['hapticEnabled'] as bool? ?? true,
        contextSnapshot: CheckinState.fromName(args['contextSnapshot'] as String?),
      );
    }

    return const SosEntryArgs(contextAvailable: false, sensorAvailable: false);
  }

  final CheckinState? contextSnapshot;
  final bool contextAvailable;
  final bool sensorAvailable;
  final bool hapticEnabled;
}

class SosActiveArgs {
  const SosActiveArgs({
    required this.mode,
    required this.contextSnapshot,
    required this.contextAvailable,
    required this.sensorAvailable,
    required this.hapticEnabled,
    this.decisionReason,
    this.initialElapsedSeconds = 0,
  });

  factory SosActiveArgs.fromDynamic(Object? args) {
    if (args is SosActiveArgs) {
      return args;
    }

    if (args is Map) {
      final value = args['mode'];
      final mode = value is SosMode
          ? value
          : value is String && value == 'active'
              ? SosMode.active
              : SosMode.calmSafe;

      return SosActiveArgs(
        mode: mode,
        contextSnapshot: CheckinState.fromName(args['contextSnapshot'] as String?),
        contextAvailable: args['contextAvailable'] as bool? ?? false,
        sensorAvailable: args['sensorAvailable'] as bool? ?? false,
        hapticEnabled: args['hapticEnabled'] as bool? ?? true,
        decisionReason: args['decisionReason'] as String?,
        initialElapsedSeconds: args['initialElapsedSeconds'] as int? ?? 0,
      );
    }

    return const SosActiveArgs(
      mode: SosMode.calmSafe,
      contextSnapshot: null,
      contextAvailable: false,
      sensorAvailable: false,
      hapticEnabled: true,
    );
  }

  final SosMode mode;
  final CheckinState? contextSnapshot;
  final bool contextAvailable;
  final bool sensorAvailable;
  final bool hapticEnabled;
  final String? decisionReason;
  final int initialElapsedSeconds;
}
