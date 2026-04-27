// lib/models/canvas_item.dart

enum CanvasItemType { image, shape, text, emoji }

class CanvasItem {
  final CanvasItemType type;
  final dynamic data;
  bool locked;

  CanvasItem({required this.type, required this.data, this.locked = false});

  CanvasItem copyWithLocked(bool locked) =>
      CanvasItem(type: type, data: data, locked: locked);
}
