import 'package:flutter/material.dart';

class EmojiPickerPanel extends StatelessWidget {
  final ValueChanged<String> onSelect;
  final VoidCallback onClose;

  const EmojiPickerPanel({
    super.key,
    required this.onSelect,
    required this.onClose,
  });

  static const _emojis = [
    '😀',
    '😎',
    '🤩',
    '😍',
    '🥳',
    '🎉',
    '🔥',
    '⚡',
    '💎',
    '🦊',
    '🐯',
    '🦁',
    '🌈',
    '⭐',
    '🌟',
    '💫',
    '🎨',
    '🎭',
    '🎪',
    '🏆',
    '👑',
    '💰',
    '🚀',
    '🌍',
    '❤️',
    '💜',
    '💙',
    '💚',
    '🧡',
    '💛',
    '🖤',
    '🤍',
    '🎵',
    '🎶',
    '🎸',
    '🎺',
    '🍕',
    '🍔',
    '🦄',
    '🐉',
    '🦋',
    '🌺',
    '🌸',
    '🍀',
    '🎃',
    '🎄',
    '🎁',
    '🎈',
  ];

  @override
  Widget build(BuildContext context) {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Emojis & Stickers',
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
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _emojis
                .map(
                  (e) => GestureDetector(
                    onTap: () => onSelect(e),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF444444),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(e, style: const TextStyle(fontSize: 22)),
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
