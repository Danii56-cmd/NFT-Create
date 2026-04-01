import 'package:flutter/material.dart';
import 'package:nft_create/enums.dart';
import 'package:nft_create/view/create_screens.dart';

class ShapeItem {
  final ShapeType type;
  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;
  final bool isDrawing;

  ShapeItem({
    required this.type,
    required this.start,
    required this.end,
    required this.color,
    required this.strokeWidth,
    required this.isDrawing,
  });
}
