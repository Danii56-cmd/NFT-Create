import 'package:flutter/material.dart';

const kOrange = Color(0xFFF5A623);

class LayerPanel extends StatelessWidget {
  final List<String> layers;
  final int activeIndex;
  final VoidCallback onAdd;
  final ValueChanged<int> onSelect;
  final VoidCallback onClose;

  const LayerPanel({
    super.key,
    required this.layers,
    required this.activeIndex,
    required this.onAdd,
    required this.onSelect,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
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
                'Layers',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onAdd,
                    child: const Icon(Icons.add, color: kOrange, size: 18),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onClose,
                    child: const Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...layers.asMap().entries.map(
            (e) => GestureDetector(
              onTap: () => onSelect(e.key),
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: activeIndex == e.key
                      ? kOrange.withOpacity(0.2)
                      : const Color(0xFF444444),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: activeIndex == e.key ? kOrange : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.layers,
                      color: activeIndex == e.key ? kOrange : Colors.grey,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      e.value,
                      style: TextStyle(
                        color: activeIndex == e.key
                            ? Colors.white
                            : Colors.grey,
                        fontSize: 12,
                        fontWeight: activeIndex == e.key
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
