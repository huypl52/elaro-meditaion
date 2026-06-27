import 'package:flutter/material.dart';

class SoftTimer extends StatelessWidget {
  const SoftTimer({
    super.key,
    required this.totalSeconds,
    required this.elapsedSeconds,
    this.label,
  });

  final int totalSeconds;
  final int elapsedSeconds;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final remaining = (totalSeconds - elapsedSeconds).clamp(0, totalSeconds);
    final minute = remaining ~/ 60;
    final second = remaining % 60;

    return Column(
      key: const Key('soft-timer'),
      children: [
        Text(
          '${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        if (label != null)
          Text(
            label!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 180,
    this.strokeWidth = 10,
  });

  final double progress;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final boundedProgress = progress.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: boundedProgress,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class BreathingCircle extends StatelessWidget {
  const BreathingCircle({
    super.key,
    required this.elapsedSeconds,
    required this.maxSize,
    this.phaseDuration = const Duration(seconds: 4),
  });

  final int elapsedSeconds;
  final int maxSize;
  final Duration phaseDuration;

  @override
  Widget build(BuildContext context) {
    final segment = phaseDuration.inSeconds <= 0 ? 1 : phaseDuration.inSeconds;
    final phaseIndex = segment == 0 ? 0 : ((elapsedSeconds ~/ segment) % 4);
    final remaining = elapsedSeconds % segment;
    final secondsToNext = (segment - remaining).clamp(0, segment);
    final phaseLabel = _phaseLabel(phaseIndex);

    return SizedBox(
      width: maxSize.toDouble(),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    phaseLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text('$secondsToNext giây tới nhịp tiếp theo'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _phaseLabel(int phaseIndex) {
    return switch (phaseIndex) {
      0 => 'Hít vào',
      1 => 'Giữ',
      2 => 'Thở ra',
      _ => 'Giữ',
    };
  }
}

class SessionStateLabel extends StatelessWidget {
  const SessionStateLabel({
    super.key,
    required this.isPaused,
    required this.isComplete,
    required this.elapsedSeconds,
  });

  final bool isPaused;
  final bool isComplete;
  final int elapsedSeconds;

  @override
  Widget build(BuildContext context) {
    return Text(
      _label,
      style: Theme.of(context).textTheme.titleMedium,
      textAlign: TextAlign.center,
    );
  }

  String get _label {
    if (isPaused) {
      return 'Nghỉ một nhịp.';
    }

    if (isComplete) {
      return elapsedSeconds % 2 == 0 ? 'Phiên đã hoàn tất.' : 'Bạn có thể dừng ở đây.';
    }

    return elapsedSeconds % 2 == 0 ? 'Cùng nhau thở.' : 'Giữ nhịp chậm — không cần hoàn hảo.';
  }
}
