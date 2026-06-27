part of 'package:elaro_mobile/features/ritual/ritual.dart';

class _RitualRuntime {
  const _RitualRuntime();

  static final List<_RitualDefinition> _rituals = <_RitualDefinition>[];

  _RitualDefinition? get latestRitual {
    if (_rituals.isEmpty) {
      return null;
    }
    return _rituals.last;
  }

  _RitualDefinition createRitual({
    required String name,
    required List<String> steps,
  }) {
    final createdAt = DateTime.now().toUtc();
    final ritual = _RitualDefinition(
      id: _uuidV7Style(createdAt),
      name: name,
      steps: List.unmodifiable(steps),
      estimatedSeconds: _estimateSeconds(steps.length),
      createdAt: createdAt,
    );
    _rituals.add(ritual);
    return ritual;
  }

  static int _estimateSeconds(int stepCount) {
    return (20 + (stepCount - 1) * 15).clamp(20, 90).toInt();
  }

  static String _uuidV7Style(DateTime at) {
    final millisHex =
        at.millisecondsSinceEpoch.toRadixString(16).padLeft(12, '0');
    final microsHex =
        at.microsecondsSinceEpoch.toRadixString(16).padLeft(20, '0');
    final tail = microsHex.substring(microsHex.length - 20);
    return '$millisHex-7${tail.substring(1, 4)}-${tail.substring(4, 8)}-${tail.substring(8, 12)}-${tail.substring(12, 20)}';
  }

  void resetForTests() {
    _rituals.clear();
  }
}

class _RitualDefinition {
  const _RitualDefinition({
    required this.id,
    required this.name,
    required this.steps,
    required this.estimatedSeconds,
    required this.createdAt,
  });

  final String id;
  final String name;
  final List<String> steps;
  final int estimatedSeconds;
  final DateTime createdAt;
}

void resetRitualRuntimeForTests() {
  const _RitualRuntime().resetForTests();
}
