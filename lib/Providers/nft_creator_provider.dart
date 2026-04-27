<<<<<<< HEAD
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nft_create/enums.dart' hide ImageFilter;
=======
// lib/providers/nft_creator_provider.dart

import 'dart:io';
import 'dart:typed_data'; // ← Added this import
import 'package:flutter/material.dart';
import 'package:nft_create/enums.dart';
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
import 'package:nft_create/models/canvas_item.dart';
import 'package:nft_create/models/drawing_point.dart';
import 'package:nft_create/models/emoji_item.dart';
import 'package:nft_create/models/image_item.dart';
<<<<<<< HEAD
import 'package:nft_create/models/layer_data.dart';
=======
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
import 'package:nft_create/models/shape_item.dart';
import 'package:nft_create/models/text_item.dart';

class NFTCreatorProvider extends ChangeNotifier {
<<<<<<< HEAD
=======
  // ── Toolbar ───────────────────────────────
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
  bool toolbarVisible = false;

  void showToolbar() {
    toolbarVisible = true;
    notifyListeners();
  }

  void hideToolbar() {
    toolbarVisible = false;
    notifyListeners();
  }

  // ── Drawing State ─────────────────────────
  List<List<DrawingPoint?>> strokes = [];
  List<DrawingPoint?> currentStroke = [];
  List<List<DrawingPoint?>> undoStack = [];

  // ── Tool State ────────────────────────────
<<<<<<< HEAD
  DrawingTool tool = DrawingTool.none;
=======
  DrawingTool tool = DrawingTool.pen;
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
  Color strokeColor = Colors.black;
  double strokeWidth = 4.0;
  double strokeOpacity = 1.0;
  PenStyle penStyle = PenStyle.pen;
<<<<<<< HEAD
=======

>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
  // ── Background ────────────────────────────
  Color bgColor = Colors.white;
  Color bgColor2 = const Color(0xFFE0E0E0);
  BgStyle bgStyle = BgStyle.solid;

<<<<<<< HEAD
  // ── Shape
=======
  // ── Shape ─────────────────────────────────
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
  ShapeType shapeType = ShapeType.rectangle;
  Offset? shapeStart;
  ShapeItem? _activeDrawingShape;

<<<<<<< HEAD
  // ── Emoji
  String? addingEmoji;

  // ── Text
  Offset textPosition = const Offset(100, 200);

  // ── Layers ────────────────────────────────
  List<LayerData> layers = [LayerData(name: 'Layer 1')];
  int activeLayer = 0;
  List<ShapeItem> get shapes => canvasItems
      .where((item) => item.type == CanvasItemType.shape)
      .map((item) => item.data as ShapeItem)
      .toList();
=======
  // ── Emoji ─────────────────────────────────
  String? addingEmoji;

  // ── Text ──────────────────────────────────
  Offset textPosition = const Offset(100, 200);

  // ── Layers ────────────────────────────────
  List<String> layers = ['Layer 1'];
  int activeLayer = 0;

>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
  // ── Unified Canvas Items ──────────────────
  final List<CanvasItem> canvasItems = [];

  // ── Panel Visibility ──────────────────────
  bool showColorPicker = false;
  bool showStrokeSlider = false;
  bool showShapePicker = false;
  bool showEmojiPicker = false;
  bool showLayerPanel = false;
  bool showImagePicker = false;
  bool showTextInput = false;
  bool showOpacitySlider = false;
  bool showPenStylePicker = false;
  bool showBgPicker = false;

  void addImageFromBytes(Uint8List bytes, String name) {
    if (bytes.isEmpty) {
<<<<<<< HEAD
      debugPrint('❌ addImageFromBytes: received empty bytes');
      return;
    }

    canvasItems.add(
      CanvasItem(
        type: CanvasItemType.image,
        data: ImageItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          bytes: bytes,
          name: name,
          position: const Offset(120, 120),
          scale: 1.0,
          filter: ImageFilter.none,
        ),
      ),
    );

    // ── Close the image picker panel (camera bypasses addImage so we do it here)
    showImagePicker = false;

    notifyListeners();
    debugPrint('✅ Image added from bytes | ${bytes.length} bytes | $name');
=======
      print("❌ addImageFromBytes: Received empty bytes");
      return;
    }

    final imageItem = ImageItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bytes: bytes, // ← Crucial
      name: name,
      position: const Offset(120, 120),
      scale: 1.0,
      filter: ImageFilter.none,
    );

    canvasItems.add(CanvasItem(type: CanvasItemType.image, data: imageItem));

    notifyListeners();
    print("✅ AI Image added | ${bytes.length} bytes");
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
  }

  // ─────────────────────────────────────────
  // BACKGROUND DECORATION
  // ─────────────────────────────────────────

  BoxDecoration get bgDecoration {
    switch (bgStyle) {
      case BgStyle.solid:
        return BoxDecoration(color: bgColor);
      case BgStyle.linearGradient:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor, bgColor2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case BgStyle.radialGradient:
        return BoxDecoration(
          gradient: RadialGradient(colors: [bgColor, bgColor2], radius: 1.0),
        );
      case BgStyle.dots:
      case BgStyle.lines:
      case BgStyle.grid:
        return BoxDecoration(color: bgColor);
    }
  }

  // ─────────────────────────────────────────
  // PAINT HELPER
  // ─────────────────────────────────────────

  Paint makePaint() {
    final color = (tool == DrawingTool.eraser ? bgColor : strokeColor)
        .withOpacity(tool == DrawingTool.eraser ? 1.0 : strokeOpacity);

    return Paint()
      ..color = color
      ..strokeWidth = tool == DrawingTool.eraser
          ? strokeWidth * 4
          : penStyle == PenStyle.marker
          ? strokeWidth * 2.5
          : penStyle == PenStyle.spray
          ? strokeWidth * 3
          : strokeWidth
      ..strokeCap = penStyle == PenStyle.pencil
          ? StrokeCap.square
          : StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = penStyle == PenStyle.spray
          ? const MaskFilter.blur(BlurStyle.normal, 4)
          : null;
  }

  // ─────────────────────────────────────────
  // TOOL SETTERS
  // ─────────────────────────────────────────

  void setTool(DrawingTool newTool) {
    tool = newTool;
    notifyListeners();
  }

  void setStrokeColor(Color color) {
    strokeColor = color;
    showColorPicker = false;
    notifyListeners();
  }

  void setBgColor(Color color) {
    bgColor = color;
    notifyListeners();
  }

  void setBgColor2(Color color) {
    bgColor2 = color;
    notifyListeners();
  }

  void setBgStyle(BgStyle style) {
    bgStyle = style;
    notifyListeners();
  }

  void setStrokeWidth(double width) {
    strokeWidth = width;
    notifyListeners();
  }

  void setStrokeOpacity(double opacity) {
    strokeOpacity = opacity;
    notifyListeners();
  }

  void setPenStyle(PenStyle style) {
    penStyle = style;
    tool = DrawingTool.pen;
    showPenStylePicker = false;
    notifyListeners();
  }

  void setShapeType(ShapeType type) {
    shapeType = type;
    tool = DrawingTool.shapes;
    showShapePicker = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // PANEL TOGGLES
  // ─────────────────────────────────────────

  void _closeAllPanels() {
    showColorPicker = false;
    showStrokeSlider = false;
    showShapePicker = false;
    showEmojiPicker = false;
    showLayerPanel = false;
    showImagePicker = false;
    showOpacitySlider = false;
    showPenStylePicker = false;
    showBgPicker = false;
  }

  void closeAllPanels() {
    _closeAllPanels();
    notifyListeners();
  }

  void toggleColorPicker() {
    final c = showColorPicker;
    _closeAllPanels();
    showColorPicker = !c;
<<<<<<< HEAD
=======
    tool = DrawingTool.pen;
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
    notifyListeners();
  }

  void toggleStrokeSlider() {
    final c = showStrokeSlider;
    _closeAllPanels();
    showStrokeSlider = !c;
    notifyListeners();
  }

  void toggleOpacitySlider() {
    final c = showOpacitySlider;
    _closeAllPanels();
    showOpacitySlider = !c;
    notifyListeners();
  }

  void togglePenStylePicker() {
    final c = showPenStylePicker;
    _closeAllPanels();
    showPenStylePicker = !c;
    notifyListeners();
  }

  void toggleBgPicker() {
    final c = showBgPicker;
    _closeAllPanels();
    showBgPicker = !c;
    notifyListeners();
  }

  void toggleShapePicker() {
    final c = showShapePicker;
    _closeAllPanels();
    showShapePicker = !c;
    notifyListeners();
  }

  void toggleEmojiPicker() {
    final c = showEmojiPicker;
    _closeAllPanels();
    showEmojiPicker = !c;
    notifyListeners();
  }

  void toggleLayerPanel() {
    final c = showLayerPanel;
    _closeAllPanels();
    showLayerPanel = !c;
    notifyListeners();
  }

  void toggleImagePicker() {
    final c = showImagePicker;
    _closeAllPanels();
    showImagePicker = !c;
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // GESTURE HANDLERS
  // ─────────────────────────────────────────

  void handleTapDown(Offset position) {
<<<<<<< HEAD
    // Always show toolbar if it's hidden
=======
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
    if (!toolbarVisible) {
      toolbarVisible = true;
      notifyListeners();
      return;
    }
<<<<<<< HEAD

=======
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
    if (addingEmoji != null) {
      canvasItems.add(
        CanvasItem(
          type: CanvasItemType.emoji,
          data: EmojiItem(addingEmoji!, position),
        ),
      );
      addingEmoji = null;
      notifyListeners();
      return;
    }
    if (tool == DrawingTool.text) {
      textPosition = position;
      showTextInput = true;
      notifyListeners();
    }
  }

  void handlePanStart(Offset position) {
<<<<<<< HEAD
    if (tool != DrawingTool.pen &&
        tool != DrawingTool.eraser &&
        tool != DrawingTool.shapes) {
      return;
    }

=======
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
    if (tool == DrawingTool.shapes) {
      shapeStart = position;
      notifyListeners();
      return;
    }
<<<<<<< HEAD

=======
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
    currentStroke = [DrawingPoint(position, makePaint())];
    notifyListeners();
  }

  void handlePanUpdate(Offset position) {
    if (tool == DrawingTool.shapes && shapeStart != null) {
      if (_activeDrawingShape != null) {
        final idx = canvasItems.indexWhere(
          (ci) =>
              ci.type == CanvasItemType.shape &&
              (ci.data as ShapeItem).id == _activeDrawingShape!.id,
        );
        if (idx != -1) {
          final updated = _activeDrawingShape!.copyWith(
            end: position,
            isDrawing: true,
          );
          canvasItems[idx] = CanvasItem(
            type: CanvasItemType.shape,
            data: updated,
          );
          _activeDrawingShape = updated;
        }
      } else {
        final newShape = ShapeItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: shapeType,
          start: shapeStart!,
          end: position,
          color: strokeColor,
          strokeWidth: strokeWidth,
          isDrawing: true,
        );
        _activeDrawingShape = newShape;
        canvasItems.add(CanvasItem(type: CanvasItemType.shape, data: newShape));
      }
      notifyListeners();
      return;
    }
    currentStroke.add(DrawingPoint(position, makePaint()));
    notifyListeners();
  }

  void handlePanEnd() {
    if (tool == DrawingTool.shapes) {
      if (_activeDrawingShape != null) {
        final idx = canvasItems.indexWhere(
          (ci) =>
              ci.type == CanvasItemType.shape &&
              (ci.data as ShapeItem).id == _activeDrawingShape!.id,
        );
        if (idx != -1) {
          final finished = _activeDrawingShape!.copyWith(isDrawing: false);
          canvasItems[idx] = CanvasItem(
            type: CanvasItemType.shape,
            data: finished,
          );
        }
        _activeDrawingShape = null;
      }
      shapeStart = null;
      notifyListeners();
      return;
    }
    strokes.add(List.from(currentStroke));
    currentStroke = [];
    undoStack.clear();
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // UNDO / REDO
  // ─────────────────────────────────────────

  void undo() {
    if (canvasItems.isNotEmpty) {
      canvasItems.removeLast();
    } else if (strokes.isNotEmpty) {
      undoStack.add(strokes.removeLast());
    }
    notifyListeners();
  }

  void redo() {
    if (undoStack.isNotEmpty) {
      strokes.add(undoStack.removeLast());
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // CANVAS ITEM OPERATIONS (unified)
  // ─────────────────────────────────────────

  void bringToFront(CanvasItem item) {
    canvasItems.remove(item);
    canvasItems.add(item);
    notifyListeners();
  }

<<<<<<< HEAD
  void sendToBack(CanvasItem item) {
    canvasItems.remove(item);
    canvasItems.insert(0, item);
    notifyListeners();
  }

  void bringForward(CanvasItem item) {
    final idx = canvasItems.indexOf(item);
    if (idx == -1 || idx == canvasItems.length - 1) return;
    canvasItems.removeAt(idx);
    canvasItems.insert(idx + 1, item);
    notifyListeners();
  }

  void sendBackward(CanvasItem item) {
    final idx = canvasItems.indexOf(item);
    if (idx <= 0) return;
    canvasItems.removeAt(idx);
    canvasItems.insert(idx - 1, item);
    notifyListeners();
  }

=======
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
  void deleteItem(CanvasItem item) {
    canvasItems.remove(item);
    notifyListeners();
  }

  void toggleLock(CanvasItem item) {
    final idx = canvasItems.indexOf(item);
    if (idx != -1) {
      canvasItems[idx] = item.copyWithLocked(!item.locked);
    }
    notifyListeners();
  }

  void duplicate(CanvasItem ci) {
    const off = Offset(20, 20);
    switch (ci.type) {
      case CanvasItemType.image:
        final img = ci.data as ImageItem;
        canvasItems.add(
          CanvasItem(
            type: CanvasItemType.image,
            data: ImageItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
<<<<<<< HEAD
              file: img.file, // gallery images: keep the stable file path
              bytes: img.bytes, // ← FIX: camera/AI images: preserve bytes
              name: img.name, // ← FIX: preserve name too
=======
              file: img.file,
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
              position: img.position + off,
              scale: img.scale,
              filter: img.filter,
            ),
          ),
        );
        break;
      case CanvasItemType.shape:
        final s = ci.data as ShapeItem;
        canvasItems.add(
          CanvasItem(
            type: CanvasItemType.shape,
            data: ShapeItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              type: s.type,
              start: s.start + off,
              end: s.end + off,
              color: s.color,
              strokeWidth: s.strokeWidth,
              offset: s.offset + off,
            ),
          ),
        );
        break;
      case CanvasItemType.text:
        final t = ci.data as TextItem;
        canvasItems.add(
          CanvasItem(
            type: CanvasItemType.text,
            data: TextItem(t.text, t.position + off, t.color, t.size),
          ),
        );
        break;
      case CanvasItemType.emoji:
        final e = ci.data as EmojiItem;
        canvasItems.add(
          CanvasItem(
            type: CanvasItemType.emoji,
            data: EmojiItem(e.emoji, e.position + off),
          ),
        );
        break;
    }
    notifyListeners();
  }
<<<<<<< HEAD
=======

>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
  // ─────────────────────────────────────────
  // MOVE / SCALE / FILTER
  // ─────────────────────────────────────────

  void moveItem(CanvasItem ci, Offset pos) {
    switch (ci.type) {
      case CanvasItemType.image:
        (ci.data as ImageItem).position = pos;
        break;
      case CanvasItemType.shape:
        (ci.data as ShapeItem).offset = pos;
        break;
      case CanvasItemType.text:
        (ci.data as TextItem).position = pos;
        break;
      case CanvasItemType.emoji:
        (ci.data as EmojiItem).position = pos;
        break;
    }
    notifyListeners();
  }

  void scaleImage(CanvasItem ci, double scale) {
    if (ci.type == CanvasItemType.image) {
      (ci.data as ImageItem).scale = scale;
      notifyListeners();
    }
  }

  void setImageFilter(CanvasItem ci, ImageFilter filter) {
    if (ci.type == CanvasItemType.image) {
      (ci.data as ImageItem).filter = filter;
      notifyListeners();
    }
  }

<<<<<<< HEAD
  // ADD ITEMS
=======
  // ─────────────────────────────────────────
  // ADD ITEMS
  // ─────────────────────────────────────────
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628

  void selectEmoji(String emoji) {
    addingEmoji = emoji;
    showEmojiPicker = false;
    notifyListeners();
  }

  void addText(String text, Color color, double size) {
    canvasItems.add(
      CanvasItem(
        type: CanvasItemType.text,
        data: TextItem(text, textPosition, color, size),
      ),
    );
    showTextInput = false;
    notifyListeners();
  }

  void cancelText() {
    showTextInput = false;
    notifyListeners();
  }

  void addImage(File file) {
    canvasItems.add(
      CanvasItem(
        type: CanvasItemType.image,
        data: ImageItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          file: file,
          position: const Offset(80, 150),
        ),
      ),
    );
    showImagePicker = false;
    notifyListeners();
  }

<<<<<<< HEAD
  // LAYER METHODS

  void addLayer() {
    layers.add(LayerData(name: 'Layer ${layers.length + 1}'));
=======
  // ─────────────────────────────────────────
  // LAYER METHODS
  // ─────────────────────────────────────────

  void addLayer() {
    layers.add('Layer ${layers.length + 1}');
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
    activeLayer = layers.length - 1;
    notifyListeners();
  }

  void selectLayer(int index) {
    activeLayer = index;
    notifyListeners();
  }

<<<<<<< HEAD
  void toggleLayerVisibility(int index) {
    layers[index].visible = !layers[index].visible;
    notifyListeners();
  }

  void renameLayer(int index, String name) {
    layers[index].name = name;
    notifyListeners();
  }

  void deleteLayer(int index) {
    if (layers.length <= 1) return;
    layers.removeAt(index);
    if (activeLayer >= layers.length) activeLayer = layers.length - 1;
    notifyListeners();
  }
  // CLEAR CANVAS
=======
  // ─────────────────────────────────────────
  // CLEAR CANVAS
  // ─────────────────────────────────────────
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628

  void clearCanvas() {
    strokes.clear();
    currentStroke.clear();
    undoStack.clear();
    canvasItems.clear();
    _activeDrawingShape = null;
    notifyListeners();
  }

<<<<<<< HEAD
=======
  // ─────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────

>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
  bool get isEmpty => strokes.isEmpty && canvasItems.isEmpty;
}
