import 'package:flutter/material.dart';

import '../view_models/video_gesture_controller.dart';

class GestureFeedbackOverlay extends StatelessWidget {
  const GestureFeedbackOverlay({
    required this.type,
    required this.level,
    super.key,
  });

  final GestureFeedbackType type;
  final double level;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      GestureFeedbackType.brightness => Icons.brightness_6_outlined,
      GestureFeedbackType.volume => Icons.volume_up_outlined,
    };

    final label = '${(level * 100).round()}%';

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
              width: 180,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 22),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: level.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.22),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
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
}
