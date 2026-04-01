// lib/models/image_item.dart

import 'dart:io';
import 'package:flutter/material.dart';

enum ImageFilter { none, grayscale, sepia, invert, vintage }

class ImageItem {
  final String id;
  final File file;
  Offset position;
  double scale;
  ImageFilter filter;

  ImageItem({
    required this.id,
    required this.file,
    this.position = const Offset(80, 150),
    this.scale = 1.0,
    this.filter = ImageFilter.none,
  });
}
