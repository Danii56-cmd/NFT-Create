// lib/models/emoji_item.dart

import 'dart:ui';

class EmojiItem {
  final String id;
  final String emoji;
  Offset position;

  EmojiItem(this.emoji, this.position)
    : id = DateTime.now().microsecondsSinceEpoch.toString();
}
