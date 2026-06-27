import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:elaro_mobile/runtime/dev_gate.dart';
import 'package:elaro_mobile/runtime/session.dart';
import 'package:elaro_mobile/runtime/sos_runtime.dart';

import '../../components/distress_boundary.dart';

class SosEntryScreen extends StatefulWidget {
  const SosEntryScreen({super.key, required this.args});

  final SosEntryArgs args;

  @override
  State<SosEntryScreen> createState() => _SosEntryScreenState();
}

class _SosEntryScreenState extends State<SosEntryScreen> {
  late final SosModeDecision _decision;

  @override
  void initState() {
    super.initState();
    _decision = SosRuntime.instance.evaluateMode(
      now: DateTime.now(),
      args: widget.args,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCalmSafe = _decision.mode == SosMode.calmSafe;

    return Scaffold(
      appBar: AppBar(title: const Text('SOS')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isCalmSafe
                  ? 'Không đủ điều kiện SOS nhanh, chuyển sang calm-safe.'
                  : 'Chúng tôi ở đây với bạn.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (isCalmSafe)
              const Text('Không dùng audio hoặc thao tác nhanh: nhẹ nhàng hạ dần cường độ.')
            else
              const Text('Nhấn bắt đầu để vào chu trình 60 giây hạ nhịp.'),
            const SizedBox(height: 16),
            if (isCalmSafe)
              EmergencySOSButton(
                key: const Key('sos-safe-btn'),
                icon: Icons.self_improvement,
                label: 'Yên vị',
                onPressed: () => _openActive(context, SosMode.calmSafe),
              )
            else
              EmergencySOSButton(
                key: const Key('sos-start-btn'),
                icon: Icons.air,
                label: '60 giây',
                onPressed: () => _openActive(context, SosMode.active),
              ),
            const SizedBox(height: 16),
            DistressBoundary(
              key: const Key('sos-distress-boundary'),
              onAction: () => _openSupportResourcesSheet(context),
              child: const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            if (MediaQuery.of(context).disableAnimations || !widget.args.hapticEnabled)
              const Text(
                'SOS haptic fallback: text pacing remains available.',
                key: Key('sos-haptic-text-fallback'),
              ),
            const SizedBox(height: 16),
            OutlinedButton(
              key: const Key('sos-return-btn'),
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Trở về Home an toàn'),
            ),
            if (DevGate.enabled)
              DevSection(child: Text('sos-reason: ${_decision.reason ?? 'active'}'))
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  void _openActive(BuildContext context, SosMode mode) {
    if (widget.args.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }

    if (mode == SosMode.active) {
      SosRuntime.instance.registerEntry(DateTime.now());
    }

    Navigator.of(context).pushNamed(
      '/sos/active',
      arguments: SosActiveArgs(
        mode: mode,
        contextSnapshot: widget.args.contextSnapshot,
        contextAvailable: widget.args.contextAvailable,
        sensorAvailable: widget.args.sensorAvailable,
        hapticEnabled: widget.args.hapticEnabled,
        decisionReason: _decision.reason,
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

class SosActiveScreen extends StatefulWidget {
  const SosActiveScreen({super.key, required this.args});

  final SosActiveArgs args;

  @override
  State<SosActiveScreen> createState() => _SosActiveScreenState();
}

class _SosActiveScreenState extends State<SosActiveScreen> {
  static const int _timeoutSeconds = 60;
  static const int _breathingPhaseSeconds = 4;

  int _elapsedSeconds = 0;
  bool _isCalmSafe = false;
  bool _timedOut = false;
  bool _timeoutRecorded = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _elapsedSeconds = widget.args.initialElapsedSeconds;
    _isCalmSafe = widget.args.mode == SosMode.calmSafe;

    if (!_isCalmSafe) {
      if (_elapsedSeconds >= _timeoutSeconds) {
        _onTimeout();
      } else {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            return;
          }

          setState(() {
            _elapsedSeconds += 1;
            if (_elapsedSeconds >= _timeoutSeconds) {
              _onTimeout();
            }
          });
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onTimeout() {
    if (_timeoutRecorded) {
      return;
    }

    _timeoutRecorded = true;
    _isCalmSafe = true;
    _timedOut = true;
    _timer?.cancel();
    const SessionRuntime().recordSosTimeoutExit();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final safeMode = _isCalmSafe;
    final elapsed = _elapsedSeconds.clamp(0, _timeoutSeconds);

    return Scaffold(
      appBar: AppBar(title: const Text('SOS')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (safeMode)
              Text(
                'Calm-safe exit: hạ cường độ, quay ra an toàn.',
                key: const Key('sos-safe-exit-copy'),
                style: Theme.of(context).textTheme.titleLarge,
              )
            else ...[
              Text(
                'Cùng nhịp thở, giữ chậm lại.',
                key: const Key('sos-active-headline'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Không cần hoàn hảo, chỉ cần quay về.'),
            ],
            const SizedBox(height: 16),
            if (!safeMode) ...[
              ProgressRing(progress: elapsed / _timeoutSeconds),
              const SizedBox(height: 8),
              BreathingCircle(
                phaseLabel: _phaseLabel(elapsed),
                secondsRemaining: _secondsToNextPhase(elapsed),
              ),
              const SizedBox(height: 16),
            ],
            DistressBoundary(
              key: const Key('sos-active-distress-boundary'),
              onAction: () => _openSupportResourcesSheet(context),
              child: const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            if (safeMode)
              FilledButton(
                key: const Key('sos-calm-safe-return'),
                onPressed: () => _returnToHome(recordInterrupt: false),
                child: const Text('Trở về Home an toàn'),
              )
            else ...[
              OutlinedButton(
                key: const Key('sos-active-exit'),
                onPressed: () => _returnToHome(recordInterrupt: true),
                child: const Text('Trở về Home an toàn'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                key: const Key('sos-exit-btn'),
                onPressed: () => _returnToHome(recordInterrupt: true),
                child: const Text('Trở về Home an toàn'),
              ),
            ],
            const SizedBox(height: 12),
            if (MediaQuery.of(context).disableAnimations || !widget.args.hapticEnabled)
              const Text(
                'SOS haptic fallback: text pacing remains available.',
                key: Key('sos-haptic-text-fallback'),
              )
            else
              Text('Nhịp chậm đang chạy: ${_phaseLabel(elapsed)} (${_secondsToNextPhase(elapsed)}s)'),
            if (DevGate.enabled)
              DevSection(
                child: Text('sos-reason: ${widget.args.decisionReason ?? 'active'} | elapsed=${elapsed}s'),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  int _secondsToNextPhase(int elapsed) {
    final mod = elapsed % _breathingPhaseSeconds;
    return _breathingPhaseSeconds - mod;
  }

  String _phaseLabel(int elapsed) {
    return switch ((elapsed ~/ _breathingPhaseSeconds) % 4) {
      0 => 'Hít vào',
      1 => 'Giữ',
      2 => 'Thở ra',
      _ => 'Giữ',
    };
  }

  void _returnToHome({required bool recordInterrupt}) {
    if (recordInterrupt && !_isCalmSafe && !_timedOut) {
      const SessionRuntime().recordSosInterrupt(reason: 'sos_interrupt');
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _openSupportResourcesSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const SupportResourcesSheet(),
    );
  }
}

class EmergencySOSButton extends StatelessWidget {
  const EmergencySOSButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label)),
    );
  }
}

class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: CircularProgressIndicator(value: progress),
    );
  }
}

class BreathingCircle extends StatelessWidget {
  const BreathingCircle({
    super.key,
    required this.phaseLabel,
    required this.secondsRemaining,
  });

  final String phaseLabel;
  final int secondsRemaining;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Pacing: $phaseLabel', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Thay đổi trong $secondsRemaining giây'),
          ],
        ),
      ),
    );
  }
}

