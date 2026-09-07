import 'package:flutter/material.dart';

class SeekFeedbackOverlay extends StatelessWidget {
  const SeekFeedbackOverlay({
    required this.position,
    required this.duration,
    super.key,
  });

  final Duration position;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final totalMs = duration.inMilliseconds <= 0 ? 1 : duration.inMilliseconds;
    final posMs = position.inMilliseconds.clamp(0, totalMs);
    final progress = posMs / totalMs;

    return IgnorePointer(
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              width: 220,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fast_forward, color: Colors.white, size: 20),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.22),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_fmt(position)} / ${_fmt(duration)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:$m:$s';
    }

    return '$m:$s';
  }
}
