import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:elaro_mobile/domain/reflection.dart';
import 'package:elaro_mobile/features/session/session.dart';

import 'app_config.dart';
import 'sensor_runtime.dart';

class AiConsentRuntime {
  AiConsentRuntime._();

  static final AiConsentRuntime instance = AiConsentRuntime._();

  final ValueNotifier<bool> _optedInNotifier = ValueNotifier<bool>(false);

  ValueListenable<bool> get optedInListenable => _optedInNotifier;
  bool get optedIn => _optedInNotifier.value;

  void setOptedIn(bool value) {
    _optedInNotifier.value = value;
  }

  void resetForTests() {
    _optedInNotifier.value = false;
  }
}

class EnvironmentalContextRuntime {
  EnvironmentalContextRuntime._();

  static final EnvironmentalContextRuntime instance =
      EnvironmentalContextRuntime._();

  EnvironmentalContextEvidence? _overrideForTests;

  EnvironmentalContextEvidence? sample({
    required bool hasMicrophone,
    required bool lowConfidence,
    required CheckinState? manualCheckin,
  }) {
    if (_overrideForTests != null) {
      return _overrideForTests;
    }

    if (!hasMicrophone || !SensorRuntime.instance.sensorAvailable) {
      return null;
    }

    if (lowConfidence) {
      return const EnvironmentalContextEvidence(
        contextTag: 'white-noise',
        classification: 'low-confidence',
        relativeNoiseLevel: EnvironmentalNoiseLevel.medium,
        confidence: 0.34,
      );
    }

    return switch (manualCheckin) {
      CheckinState.overload => const EnvironmentalContextEvidence(
          contextTag: 'urban-vibe',
          classification: 'busy-street',
          relativeNoiseLevel: EnvironmentalNoiseLevel.high,
          confidence: 0.82,
          soundscapeSuggestion: 'tiếng mưa nhẹ',
        ),
      CheckinState.low => const EnvironmentalContextEvidence(
          contextTag: 'white-noise',
          classification: 'steady-hum',
          relativeNoiseLevel: EnvironmentalNoiseLevel.high,
          confidence: 0.74,
          soundscapeSuggestion: 'white noise dịu',
        ),
      CheckinState.calm => const EnvironmentalContextEvidence(
          contextTag: 'absolute-silence',
          classification: 'quiet-room',
          relativeNoiseLevel: EnvironmentalNoiseLevel.low,
          confidence: 0.88,
        ),
      null => const EnvironmentalContextEvidence(
          contextTag: 'nature',
          classification: 'steady-breath',
          relativeNoiseLevel: EnvironmentalNoiseLevel.medium,
          confidence: 0.68,
        ),
    };
  }

  void setEvidenceForTests(EnvironmentalContextEvidence? value) {
    _overrideForTests = value;
  }

  void resetForTests() {
    _overrideForTests = null;
  }
}

class ReflectionRuntime {
  ReflectionRuntime._();

  static final ReflectionRuntime instance = ReflectionRuntime._();

  Future<ReflectionInsight> Function(ReflectionSummary summary)?
      _handlerForTests;
  Map<String, Object?>? _lastPayloadForTests;

  Map<String, Object?>? get lastPayloadForTests => _lastPayloadForTests;

  Future<ReflectionInsight> buildEmpatheticInsight({
    required ReflectionSummary summary,
  }) async {
    final payload = _sanitizeProviderPayload(summary.toProviderPayload());
    _lastPayloadForTests = payload;

    if (!AiConsentRuntime.instance.optedIn) {
      return _buildLocalFallback(summary);
    }

    if (_handlerForTests != null) {
      return _handlerForTests!(summary);
    }

    if (!AppConfig.hasOpenAiKey) {
      return _buildLocalFallback(summary);
    }

    try {
      final client = HttpClient();
      final request = await client
          .postUrl(Uri.parse('${AppConfig.openAiBaseUrl}/v1/chat/completions'))
          .timeout(const Duration(seconds: 8));
      request.headers.contentType = ContentType.json;
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer ${AppConfig.openAiApiKey}',
      );
      request.write(
        jsonEncode(<String, Object?>{
          'model': AppConfig.openAiModel,
          'temperature': 0.5,
          'max_tokens': 120,
          'messages': <Map<String, String>>[
            const <String, String>{
              'role': 'system',
              'content':
                  'Bạn là trợ lý phản chiếu thiền định. Hãy viết đúng 1 đoạn ngắn bằng tiếng Việt, dịu, không chẩn đoán, không ra lệnh, không chấm điểm, không so sánh. Xác nhận trải nghiệm của người dùng một cách ấm áp.',
            },
            <String, String>{
              'role': 'user',
              'content': jsonEncode(payload),
            },
          ],
        }),
      );

      final response = await request.close().timeout(const Duration(seconds: 8));
      final body = await response.transform(utf8.decoder).join();
      client.close(force: true);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _buildLocalFallback(summary);
      }

      final decoded = jsonDecode(body);
      final message = _extractCompletionMessage(decoded);
      if (message == null || message.trim().isEmpty) {
        return _buildLocalFallback(summary);
      }
      return ReflectionInsight(message: message.trim(), source: 'provider');
    } catch (_) {
      return _buildLocalFallback(summary);
    }
  }

  Map<String, Object?> _sanitizeProviderPayload(Map<String, Object?> payload) {
    final sanitized = Map<String, Object?>.from(payload);
    const bannedKeys = <String>{
      'raw_audio',
      'raw_voice_journal',
      'raw_health_samples',
      'identifiers',
      'private_journal_content',
      'user_email',
      'device_serial',
    };
    sanitized.removeWhere((key, _) => bannedKeys.contains(key));
    return sanitized;
  }

  ReflectionInsight _buildLocalFallback(ReflectionSummary summary) {
    final contextTag = summary.environmentalContext?.contextTag;
    final contextLine = switch (contextTag) {
      'urban-vibe' => 'Môi trường quanh bạn có vẻ hơi dày tín hiệu, nhưng bạn vẫn dành được một khoảng lùi cho mình.',
      'white-noise' => 'Dù quanh bạn còn nền âm thanh đều đều, bạn vẫn đang tạo được một vùng thở riêng.',
      'absolute-silence' => 'Sự yên vừa đủ quanh bạn đang nâng đỡ nhịp quay về của phiên này.',
      'nature' => 'Bối cảnh quanh bạn khá mềm, giúp phiên này đi theo nhịp tự nhiên hơn.',
      _ => 'Phiên này cho thấy bạn vẫn có thể quay về với nhịp của mình theo cách nhẹ nhàng.',
    };
    final bioLine = summary.biofeedbackSummary == null
        ? 'Cứ giữ cảm nhận này như một ghi chú dịu, không cần đo đếm thêm.'
        : 'Cơ thể của bạn cũng đang cho thấy một chiều hướng đáng lắng nghe, không phải để chấm điểm.';
    return ReflectionInsight(
      message: '$contextLine $bioLine',
      source: 'local-fallback',
    );
  }

  String? _extractCompletionMessage(Object? decoded) {
    if (decoded is! Map) {
      return null;
    }
    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) {
      return null;
    }
    final first = choices.first;
    if (first is! Map) {
      return null;
    }
    final message = first['message'];
    if (message is! Map) {
      return null;
    }
    final content = message['content'];
    return content is String ? content : null;
  }

  void setHandlerForTests(
    Future<ReflectionInsight> Function(ReflectionSummary summary)? handler,
  ) {
    _handlerForTests = handler;
  }

  void resetForTests() {
    _handlerForTests = null;
    _lastPayloadForTests = null;
    AiConsentRuntime.instance.resetForTests();
    EnvironmentalContextRuntime.instance.resetForTests();
  }
}
