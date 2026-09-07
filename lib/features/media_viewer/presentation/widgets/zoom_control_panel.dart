import 'package:flutter/material.dart';

class ZoomControlPanel extends StatelessWidget {
  const ZoomControlPanel({
    super.key,
    required this.currentScale,
    required this.onSetZoom,
    required this.onClose,
  });

  final double currentScale;
  final ValueChanged<double> onSetZoom;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final roundedScale = (currentScale * 10).round() / 10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.zoom_in_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Zoom: ${roundedScale.toStringAsFixed(1)}x',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                onPressed: onClose,
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
                tooltip: 'Cerrar zoom',
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                onPressed: () {
                  final next = (currentScale - 0.5).clamp(1.0, 4.0);
                  onSetZoom(next);
                },
                icon: const Icon(
                  Icons.remove_circle_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: 'Alejar (-)',
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                  ),
                  child: Slider(
                    value: roundedScale.clamp(1.0, 4.0),
                    min: 1.0,
                    max: 4.0,
                    divisions: 30,
                    onChanged: onSetZoom,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                onPressed: () {
                  final next = (currentScale + 0.5).clamp(1.0, 4.0);
                  onSetZoom(next);
                },
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: 'Acercar (+)',
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [1.0, 1.5, 2.0, 3.0, 4.0].map((scale) {
                final isSelected = (roundedScale - scale).abs() < 0.1;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: ChoiceChip(
                    label: Text(
                      '${scale.toStringAsFixed(1)}x',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Colors.white,
                    backgroundColor: Colors.white12,
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 0,
                    ),
                    onSelected: (_) => onSetZoom(scale),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
