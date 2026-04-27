// lib/models/image_item.dart

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

enum ImageFilter { none, grayscale, sepia, invert, vintage }

class ImageItem {
  final String id;
  final File? file; // nullable - for AI generated images
  final Uint8List? bytes; // for AI generated images (memory)
  final String? name; // optional name for AI images
  Offset position;
  double scale;
  ImageFilter filter;

  ImageItem({
    required this.id,
    this.file, // optional
    this.bytes, // optional
    this.name,
    this.position = const Offset(100, 100),
    this.scale = 1.0,
    this.filter = ImageFilter.none,
  });
}
