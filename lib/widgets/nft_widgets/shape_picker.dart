import 'package:flutter/material.dart';
import 'package:nft_create/enums.dart';

const kOrange = Color(0xFFF5A623);

class ShapePickerPanel extends StatelessWidget {
  final ShapeType selected;
  final ValueChanged<ShapeType> onSelect;
  final VoidCallback onClose;

  const ShapePickerPanel({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final shapes = [
      (ShapeType.rectangle, Icons.crop_square, 'Rectangle'),
      (ShapeType.circle, Icons.circle_outlined, 'Circle'),
      (ShapeType.line, Icons.remove, 'Line'),
      (ShapeType.triangle, Icons.change_history, 'Triangle'),
    ];

    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Shapes',
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
          const SizedBox(height: 10),
          Row(
            children: shapes
                .map(
                  (s) => GestureDetector(
                    onTap: () => onSelect(s.$1),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected == s.$1
                            ? kOrange
                            : const Color(0xFF444444),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Icon(s.$2, color: Colors.white, size: 22),
                          const SizedBox(height: 4),
                          Text(
                            s.$3,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                          ),
                        ],
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
