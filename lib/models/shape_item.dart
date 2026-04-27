// lib/models/shape_item.dart

import 'package:flutter/material.dart';
import 'package:nft_create/enums.dart';

class ShapeItem {
  final String id;
  final ShapeType type;
  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;
  final bool isDrawing;
  Offset offset;

  ShapeItem({
    required this.id,
    required this.type,
    required this.start,
    required this.end,
    required this.color,
    required this.strokeWidth,
    this.isDrawing = false, // ← default false, no longer required
    this.offset = Offset.zero,
  });

  ShapeItem copyWith({Offset? end, bool? isDrawing, Offset? offset}) {
    return ShapeItem(
      id: id,
      type: type,
      start: start,
      end: end ?? this.end,
      color: color,
      strokeWidth: strokeWidth,
      isDrawing: isDrawing ?? this.isDrawing,
      offset: offset ?? this.offset,
    );
  }
}
