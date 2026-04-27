import 'package:flutter/material.dart';

const kOrange = Color(0xFFF5A623);

class ColorPickerPanel extends StatelessWidget {
  final Color selectedColor;
  final Color bgColor;
  final ValueChanged<Color> onColorSelected;
  final ValueChanged<Color> onBgColorSelected;
  final VoidCallback onClose;

  const ColorPickerPanel({
    super.key,
    required this.selectedColor,
    required this.bgColor,
    required this.onColorSelected,
    required this.onBgColorSelected,
    required this.onClose,
  });

  static const _colors = [
    Colors.black,
    Colors.white,
    Color(0xFFE53935),
    Color(0xFFFF7043),
    Color(0xFFFFC107),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFFFF4081),
    Color(0xFF795548),
    Color(0xFF607D8B),
    Color(0xFFF5A623),
    Color(0xFF00E676),
    Color(0xFF40C4FF),
    Color(0xFFEA80FC),
  ];

  static const _bgColors = [
    Colors.white,
    Color(0xFFF5F5F5),
    Color(0xFFFFF9C4),
    Color(0xFFE8F5E9),
    Color(0xFFE3F2FD),
    Color(0xFF212121),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 16),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Stroke Color',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close, color: Colors.grey, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Stroke colors
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _colors
                .map(
                  (c) => GestureDetector(
                    onTap: () => onColorSelected(c),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: selectedColor == c
                            ? Border.all(color: kOrange, width: 2.5)
                            : Border.all(color: Colors.grey.shade600, width: 1),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          const Text(
            'Background',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          // Background colors
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _bgColors
                .map(
                  (c) => GestureDetector(
                    onTap: () => onBgColorSelected(c),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: bgColor == c
                            ? Border.all(color: kOrange, width: 2.5)
                            : Border.all(color: Colors.grey.shade600, width: 1),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
