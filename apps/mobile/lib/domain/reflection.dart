enum EnvironmentalNoiseLevel {
  low('low'),
  medium('medium'),
  high('high');

  const EnvironmentalNoiseLevel(this.value);

  final String value;
}

class EnvironmentalContextEvidence {
  const EnvironmentalContextEvidence({
    required this.contextTag,
    required this.classification,
    required this.relativeNoiseLevel,
    required this.confidence,
    this.soundscapeSuggestion,
  });

  final String contextTag;
  final String classification;
  final EnvironmentalNoiseLevel relativeNoiseLevel;
  final double confidence;
  final String? soundscapeSuggestion;

  bool get highConfidence => confidence >= 0.6;
  bool get shouldSuggestSoundscape =>
      relativeNoiseLevel == EnvironmentalNoiseLevel.high &&
      soundscapeSuggestion != null &&
      soundscapeSuggestion!.isNotEmpty;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'context_tag': contextTag,
      'classification': classification,
      'relative_noise_level': relativeNoiseLevel.value,
      'confidence': confidence,
      'soundscape_suggestion': soundscapeSuggestion,
    };
  }

  factory EnvironmentalContextEvidence.fromJson(Map<String, Object?> json) {
    final level = EnvironmentalNoiseLevel.values.firstWhere(
      (candidate) => candidate.value == json['relative_noise_level'],
      orElse: () => EnvironmentalNoiseLevel.medium,
    );
    final rawConfidence = json['confidence'];
    final confidence = rawConfidence is num ? rawConfidence.toDouble() : 0.0;
    return EnvironmentalContextEvidence(
      contextTag: json['context_tag'] as String? ?? 'nature',
      classification: json['classification'] as String? ?? 'steady-breath',
      relativeNoiseLevel: level,
      confidence: confidence,
      soundscapeSuggestion: json['soundscape_suggestion'] as String?,
    );
  }
}

class ReflectionSummary {
  const ReflectionSummary({
    required this.sessionId,
    required this.sessionRoute,
    required this.elapsedSeconds,
    required this.trendCopy,
    this.environmentalContext,
    this.biofeedbackSummary,
  });

  final String sessionId;
  final String sessionRoute;
  final int elapsedSeconds;
  final String trendCopy;
  final EnvironmentalContextEvidence? environmentalContext;
  final String? biofeedbackSummary;

  Map<String, Object?> toProviderPayload() {
    return <String, Object?>{
      'session_id': sessionId,
      'session_route': sessionRoute,
      'elapsed_seconds': elapsedSeconds,
      'trend_copy': trendCopy,
      'environmental_context': environmentalContext?.toJson(),
      'biofeedback_summary': biofeedbackSummary,
    };
  }
}

class ReflectionInsight {
  const ReflectionInsight({
    required this.message,
    required this.source,
  });

  final String message;
  final String source;

  bool get fromProvider => source == 'provider';
}
