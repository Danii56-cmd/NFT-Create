// ─────────────────────────────────────────────────────────────────────────────
// opacity_slider.dart
// Floating panel that lets the user adjust the stroke opacity.
// Shows as a horizontal slider with a live percentage label.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:nft_create/constants/nft_screen_constants.dart';

class OpacitySlider extends StatelessWidget {
  final double value; // 0.1 – 1.0
  final ValueChanged<double> onChanged;
  final VoidCallback onClose;

  const OpacitySlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      child: Row(
        children: [
          const Icon(Icons.opacity, color: kOrange, size: 18),
          Expanded(
            child: Slider(
              value: value,
              min: 0.1,
              max: 1.0,
              activeColor: kOrange,
              inactiveColor: Colors.white24,
              onChanged: onChanged,
            ),
          ),
          // Live percentage label
          Text(
            '${(value * 100).round()}%',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, color: Colors.grey, size: 16),
          ),
        ],
      ),
    );
  }
}
