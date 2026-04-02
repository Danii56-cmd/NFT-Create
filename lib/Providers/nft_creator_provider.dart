// lib/providers/nft_creator_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nft_create/enums.dart';
import 'package:nft_create/models/canvas_item.dart';
import 'package:nft_create/models/drawing_point.dart';
import 'package:nft_create/models/emoji_item.dart';
import 'package:nft_create/models/image_item.dart';
import 'package:nft_create/models/shape_item.dart';
import 'package:nft_create/models/text_item.dart';

class NFTCreatorProvider extends ChangeNotifier {
  // ── Toolbar ───────────────────────────────
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
  DrawingTool tool = DrawingTool.pen;
  Color strokeColor = Colors.black;
  double strokeWidth = 4.0;
  double strokeOpacity = 1.0;
  PenStyle penStyle = PenStyle.pen;

  // ── Background ────────────────────────────
  Color bgColor = Colors.white;
  Color bgColor2 = const Color(0xFFE0E0E0);
  BgStyle bgStyle = BgStyle.solid;

  // ── Shape ─────────────────────────────────
  ShapeType shapeType = ShapeType.rectangle;
  Offset? shapeStart;
  ShapeItem? _activeDrawingShape;

  // ── Emoji ─────────────────────────────────
  String? addingEmoji;

  // ── Text ──────────────────────────────────
  Offset textPosition = const Offset(100, 200);

  // ── Layers ────────────────────────────────
  List<String> layers = ['Layer 1'];
  int activeLayer = 0;

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
    tool = DrawingTool.pen;
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
    if (!toolbarVisible) {
      toolbarVisible = true;
      notifyListeners();
      return;
    }
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
    if (tool == DrawingTool.shapes) {
      shapeStart = position;
      notifyListeners();
      return;
    }
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
              file: img.file,
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

  // ─────────────────────────────────────────
  // ADD ITEMS
  // ─────────────────────────────────────────

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

  // ─────────────────────────────────────────
  // LAYER METHODS
  // ─────────────────────────────────────────

  void addLayer() {
    layers.add('Layer ${layers.length + 1}');
    activeLayer = layers.length - 1;
    notifyListeners();
  }

  void selectLayer(int index) {
    activeLayer = index;
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // CLEAR CANVAS
  // ─────────────────────────────────────────

  void clearCanvas() {
    strokes.clear();
    currentStroke.clear();
    undoStack.clear();
    canvasItems.clear();
    _activeDrawingShape = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────

  bool get isEmpty => strokes.isEmpty && canvasItems.isEmpty;
}
