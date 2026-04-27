// lib/models/text_item.dart

import 'package:flutter/material.dart';

class TextItem {
  final String id;
  final String text;
  Offset position;
  final Color color;
  final double size;

  TextItem(this.text, this.position, this.color, this.size)
    : id = DateTime.now().microsecondsSinceEpoch.toString();
}
