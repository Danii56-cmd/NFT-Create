import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nft_create/enums.dart';
import 'package:nft_create/models/canvas_item.dart';
import 'package:nft_create/models/drawing_point.dart';
import 'package:nft_create/models/emoji_item.dart';
import 'package:nft_create/models/image_item.dart';
import 'package:nft_create/models/shape_item.dart';
import 'package:nft_create/models/text_item.dart';
import 'package:nft_create/painters/drawing_painters.dart';
import 'package:nft_create/widgets/nft_widgets/color_picker.dart';
import 'package:nft_create/widgets/nft_widgets/dragable_text.dart';
import 'package:nft_create/widgets/nft_widgets/draggable_emoji.dart';
import 'package:nft_create/widgets/nft_widgets/draggable_image.dart';
import 'package:nft_create/widgets/nft_widgets/draggable_shapes.dart';
import 'package:nft_create/widgets/nft_widgets/emoji_picker.dart';
import 'package:nft_create/widgets/nft_widgets/image_picker_panel.dart';
import 'package:nft_create/widgets/nft_widgets/layer_panel.dart';
import 'package:nft_create/widgets/nft_widgets/shape_picker.dart';
import 'package:nft_create/widgets/nft_widgets/stroke_slider.dart';
import 'package:nft_create/widgets/nft_widgets/text_input_bar.dart';

const kOrange = Color(0xFFF5A623);
const kDark = Color(0xFF2A2A2A);
const kPanel = Color(0xFF1E1E1E);

// ── Background style ──────────────────────────
enum BgStyle { solid, linearGradient, radialGradient, dots, lines, grid }

class NFTCreatorScreen extends StatefulWidget {
  const NFTCreatorScreen({super.key});
  @override
  State<NFTCreatorScreen> createState() => _NFTCreatorScreenState();
}

class _NFTCreatorScreenState extends State<NFTCreatorScreen> {
  bool _toolbarVisible = false;

  // ── Drawing ──
  List<List<DrawingPoint?>> _strokes = [];
  List<DrawingPoint?> _currentStroke = [];
  List<List<DrawingPoint?>> _undoStack = [];

  DrawingTool _tool = DrawingTool.pen;
  Color _strokeColor = Colors.black;
  double _strokeWidth = 4.0;
  double _strokeOpacity = 1.0;
  PenStyle _penStyle = PenStyle.pen;

  // ── Background ──
  Color _bgColor = Colors.white;
  Color _bgColor2 = const Color(0xFFE0E0E0);
  BgStyle _bgStyle = BgStyle.solid;
  bool _showBgPicker = false;

  // ── Panel visibility ──
  bool _showColorPicker = false;
  bool _showStrokeSlider = false;
  bool _showShapePicker = false;
  bool _showEmojiPicker = false;
  bool _showLayerPanel = false;
  bool _showImagePicker = false;
  bool _showTextInput = false;
  bool _showOpacitySlider = false;
  bool _showPenStylePicker = false;

  // ── Shape drawing ──
  ShapeType _shapeType = ShapeType.rectangle;
  Offset? _shapeStart;
  ShapeItem? _activeDrawingShape;

  // ── Emoji ──
  String? _addingEmoji;

  // ── Text ──
  Offset _textPosition = const Offset(100, 200);

  // ── Layers ──
  List<String> _layers = ['Layer 1'];
  int _activeLayer = 0;

  // ── Unified canvas items ──
  final List<CanvasItem> _canvasItems = [];

  final GlobalKey _canvasKey = GlobalKey();

  // ── Paint helper ──────────────────────────
  Paint _makePaint() {
    final color = (_tool == DrawingTool.eraser ? _bgColor : _strokeColor)
        .withOpacity(_tool == DrawingTool.eraser ? 1.0 : _strokeOpacity);

    return Paint()
      ..color = color
      ..strokeWidth = _tool == DrawingTool.eraser
          ? _strokeWidth * 4
          : _penStyle == PenStyle.marker
          ? _strokeWidth * 2.5
          : _penStyle == PenStyle.spray
          ? _strokeWidth * 3
          : _strokeWidth
      ..strokeCap = _penStyle == PenStyle.pencil
          ? StrokeCap.square
          : StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = _penStyle == PenStyle.spray
          ? const MaskFilter.blur(BlurStyle.normal, 4)
          : null;
  }

  // ── Duplicate ─────────────────────────────
  void _duplicate(CanvasItem ci) {
    setState(() {
      const offset = Offset(20, 20);
      switch (ci.type) {
        case CanvasItemType.image:
          final img = ci.data as ImageItem;
          _canvasItems.add(
            CanvasItem(
              type: CanvasItemType.image,
              data: ImageItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                file: img.file,
                position: img.position + offset,
                scale: img.scale,
                filter: img.filter,
              ),
            ),
          );
          break;
        case CanvasItemType.shape:
          final s = ci.data as ShapeItem;
          _canvasItems.add(
            CanvasItem(
              type: CanvasItemType.shape,
              data: ShapeItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                type: s.type,
                start: s.start + offset,
                end: s.end + offset,
                color: s.color,
                strokeWidth: s.strokeWidth,
                offset: s.offset,
              ),
            ),
          );
          break;
        case CanvasItemType.text:
          final t = ci.data as TextItem;
          _canvasItems.add(
            CanvasItem(
              type: CanvasItemType.text,
              data: TextItem(t.text, t.position + offset, t.color, t.size),
            ),
          );
          break;
        case CanvasItemType.emoji:
          final e = ci.data as EmojiItem;
          _canvasItems.add(
            CanvasItem(
              type: CanvasItemType.emoji,
              data: EmojiItem(e.emoji, e.position + offset),
            ),
          );
          break;
      }
    });
  }

  void _toggleLock(CanvasItem ci) {
    setState(() {
      final idx = _canvasItems.indexOf(ci);
      if (idx != -1) {
        _canvasItems[idx] = ci.copyWithLocked(!ci.locked);
      }
    });
  }

  void _bringToFront(CanvasItem item) {
    setState(() {
      _canvasItems.remove(item);
      _canvasItems.add(item);
    });
  }

  // ── Gesture Handlers ──────────────────────
  void _handleTapDown(Offset position) {
    if (!_toolbarVisible) {
      setState(() => _toolbarVisible = true);
      return;
    }
    if (_addingEmoji != null) {
      setState(() {
        _canvasItems.add(
          CanvasItem(
            type: CanvasItemType.emoji,
            data: EmojiItem(_addingEmoji!, position),
          ),
        );
        _addingEmoji = null;
      });
      return;
    }
    if (_tool == DrawingTool.text) {
      setState(() {
        _textPosition = position;
        _showTextInput = true;
      });
    }
  }

  void _handlePanStart(Offset position) {
    if (_tool == DrawingTool.shapes) {
      setState(() => _shapeStart = position);
      return;
    }
    setState(() {
      _currentStroke = [DrawingPoint(position, _makePaint())];
    });
  }

  void _handlePanUpdate(Offset position) {
    if (_tool == DrawingTool.shapes && _shapeStart != null) {
      setState(() {
        if (_activeDrawingShape != null) {
          final idx = _canvasItems.indexWhere(
            (ci) =>
                ci.type == CanvasItemType.shape &&
                (ci.data as ShapeItem).id == _activeDrawingShape!.id,
          );
          if (idx != -1) {
            final updated = _activeDrawingShape!.copyWith(
              end: position,
              isDrawing: true,
            );
            _canvasItems[idx] = CanvasItem(
              type: CanvasItemType.shape,
              data: updated,
            );
            _activeDrawingShape = updated;
          }
        } else {
          final newShape = ShapeItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: _shapeType,
            start: _shapeStart!,
            end: position,
            color: _strokeColor,
            strokeWidth: _strokeWidth,
            isDrawing: true,
          );
          _activeDrawingShape = newShape;
          _canvasItems.add(
            CanvasItem(type: CanvasItemType.shape, data: newShape),
          );
        }
      });
      return;
    }
    setState(() {
      _currentStroke.add(DrawingPoint(position, _makePaint()));
    });
  }

  void _handlePanEnd() {
    if (_tool == DrawingTool.shapes) {
      setState(() {
        if (_activeDrawingShape != null) {
          final idx = _canvasItems.indexWhere(
            (ci) =>
                ci.type == CanvasItemType.shape &&
                (ci.data as ShapeItem).id == _activeDrawingShape!.id,
          );
          if (idx != -1) {
            final finished = _activeDrawingShape!.copyWith(isDrawing: false);
            _canvasItems[idx] = CanvasItem(
              type: CanvasItemType.shape,
              data: finished,
            );
          }
          _activeDrawingShape = null;
        }
        _shapeStart = null;
      });
      return;
    }
    setState(() {
      _strokes.add(List.from(_currentStroke));
      _currentStroke = [];
      _undoStack.clear();
    });
  }

  void _undo() {
    setState(() {
      if (_canvasItems.isNotEmpty) {
        _canvasItems.removeLast();
      } else if (_strokes.isNotEmpty) {
        _undoStack.add(_strokes.removeLast());
      }
    });
  }

  void _redo() {
    setState(() {
      if (_undoStack.isNotEmpty) _strokes.add(_undoStack.removeLast());
    });
  }

  void _addText(String text, Color color, double size) {
    setState(() {
      _canvasItems.add(
        CanvasItem(
          type: CanvasItemType.text,
          data: TextItem(text, _textPosition, color, size),
        ),
      );
      _showTextInput = false;
    });
  }

  void _closeAllPanels() {
    _showColorPicker = false;
    _showStrokeSlider = false;
    _showShapePicker = false;
    _showEmojiPicker = false;
    _showLayerPanel = false;
    _showImagePicker = false;
    _showOpacitySlider = false;
    _showPenStylePicker = false;
    _showBgPicker = false;
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF333333),
        title: const Text(
          'Clear Canvas',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will erase everything. Are you sure?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kOrange),
            onPressed: () {
              setState(() {
                _strokes.clear();
                _canvasItems.clear();
                _undoStack.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Background decoration ─────────────────
  BoxDecoration _bgDecoration() {
    switch (_bgStyle) {
      case BgStyle.solid:
        return BoxDecoration(color: _bgColor);
      case BgStyle.linearGradient:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [_bgColor, _bgColor2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case BgStyle.radialGradient:
        return BoxDecoration(
          gradient: RadialGradient(colors: [_bgColor, _bgColor2], radius: 1.0),
        );
      default:
        return BoxDecoration(color: _bgColor);
    }
  }

  // ── Build canvas items ─────────────────────
  List<Widget> _buildCanvasItems() {
    return _canvasItems.map((ci) {
      switch (ci.type) {
        case CanvasItemType.image:
          final img = ci.data as ImageItem;
          return DraggableImage(
            key: ValueKey(img.id),
            item: img,
            locked: ci.locked,
            onMove: (pos) => setState(() => img.position = pos),
            onScale: (s) => setState(() => img.scale = s),
            onDelete: () => setState(() => _canvasItems.remove(ci)),
            onBringToFront: () => _bringToFront(ci),
            onDuplicate: () => _duplicate(ci),
            onToggleLock: () => _toggleLock(ci),
            onFilterChanged: (f) => setState(() => img.filter = f),
          );
        case CanvasItemType.shape:
          final s = ci.data as ShapeItem;
          return DraggableShape(
            key: ValueKey(s.id),
            item: s,
            locked: ci.locked,
            onMove: (pos) => setState(() => s.offset = pos),
            onDelete: () => setState(() => _canvasItems.remove(ci)),
            onBringToFront: () => _bringToFront(ci),
            onDuplicate: () => _duplicate(ci),
            onToggleLock: () => _toggleLock(ci),
          );
        case CanvasItemType.text:
          final t = ci.data as TextItem;
          return DraggableText(
            key: ValueKey(t.id),
            item: t,
            locked: ci.locked,
            onMove: (pos) => setState(() => t.position = pos),
            onDelete: () => setState(() => _canvasItems.remove(ci)),
            onBringToFront: () => _bringToFront(ci),
            onDuplicate: () => _duplicate(ci),
            onToggleLock: () => _toggleLock(ci),
          );
        case CanvasItemType.emoji:
          final e = ci.data as EmojiItem;
          return DraggableEmoji(
            key: ValueKey(e.id),
            item: e,
            locked: ci.locked,
            onMove: (pos) => setState(() => e.position = pos),
            onDelete: () => setState(() => _canvasItems.remove(ci)),
            onBringToFront: () => _bringToFront(ci),
            onDuplicate: () => _duplicate(ci),
            onToggleLock: () => _toggleLock(ci),
          );
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDark,
      body: SafeArea(
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              height: _toolbarVisible ? 60 : 0,
              child: _toolbarVisible ? _buildToolbar() : const SizedBox(),
            ),
            Expanded(
              child: Stack(
                children: [
                  GestureDetector(
                    onTapDown: (d) => _handleTapDown(d.localPosition),
                    onPanStart: (d) => _handlePanStart(d.localPosition),
                    onPanUpdate: (d) => _handlePanUpdate(d.localPosition),
                    onPanEnd: (_) => _handlePanEnd(),
                    child: RepaintBoundary(
                      key: _canvasKey,
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              // ── Background ──
                              Positioned.fill(
                                child: Container(
                                  decoration: _bgDecoration(),
                                  child: _bgStyle == BgStyle.dots
                                      ? CustomPaint(
                                          painter: _DotPatternPainter(
                                            _bgColor2,
                                          ),
                                        )
                                      : _bgStyle == BgStyle.lines
                                      ? CustomPaint(
                                          painter: _LinePatternPainter(
                                            _bgColor2,
                                          ),
                                        )
                                      : _bgStyle == BgStyle.grid
                                      ? CustomPaint(
                                          painter: _GridPatternPainter(
                                            _bgColor2,
                                          ),
                                        )
                                      : null,
                                ),
                              ),

                              // ── Stroke Painter ──
                              CustomPaint(
                                painter: DrawingPainter(
                                  strokes: _strokes,
                                  currentStroke: _currentStroke,
                                  shapes: const [],
                                ),
                                size: Size.infinite,
                              ),

                              // ── Canvas items ──
                              ..._buildCanvasItems(),

                              // ── Empty state ──
                              if (_strokes.isEmpty && _canvasItems.isEmpty)
                                Center(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _toolbarVisible = true),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            color: kOrange.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.palette_outlined,
                                            color: kOrange,
                                            size: 36,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Tap to start creating',
                                          style: TextStyle(
                                            color: Color(0xFFAAAAAA),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Panels ──
                  if (_showColorPicker)
                    Positioned(
                      top: 4,
                      left: 8,
                      child: ColorPickerPanel(
                        selectedColor: _strokeColor,
                        bgColor: _bgColor,
                        onColorSelected: (c) => setState(() {
                          _strokeColor = c;
                          _showColorPicker = false;
                        }),
                        onBgColorSelected: (c) => setState(() {
                          _bgColor = c;
                          _showColorPicker = false;
                        }),
                        onClose: () => setState(() => _showColorPicker = false),
                      ),
                    ),

                  if (_showStrokeSlider)
                    Positioned(
                      top: 4,
                      left: 8,
                      right: 8,
                      child: StrokeSlider(
                        value: _strokeWidth,
                        onChanged: (v) => setState(() => _strokeWidth = v),
                        onClose: () =>
                            setState(() => _showStrokeSlider = false),
                      ),
                    ),

                  // ── Opacity slider ──
                  if (_showOpacitySlider)
                    Positioned(
                      top: 4,
                      left: 8,
                      right: 8,
                      child: _OpacitySlider(
                        value: _strokeOpacity,
                        onChanged: (v) => setState(() => _strokeOpacity = v),
                        onClose: () =>
                            setState(() => _showOpacitySlider = false),
                      ),
                    ),

                  // ── Pen style picker ──
                  if (_showPenStylePicker)
                    Positioned(
                      top: 4,
                      left: 8,
                      child: _PenStylePicker(
                        selected: _penStyle,
                        onSelect: (s) => setState(() {
                          _penStyle = s;
                          _showPenStylePicker = false;
                          _tool = DrawingTool.pen;
                        }),
                        onClose: () =>
                            setState(() => _showPenStylePicker = false),
                      ),
                    ),

                  // ── Background picker ──
                  if (_showBgPicker)
                    Positioned(
                      top: 4,
                      left: 8,
                      right: 8,
                      child: _BgStylePicker(
                        selectedStyle: _bgStyle,
                        color1: _bgColor,
                        color2: _bgColor2,
                        onStyleSelected: (s) => setState(() => _bgStyle = s),
                        onColor1Changed: (c) => setState(() => _bgColor = c),
                        onColor2Changed: (c) => setState(() => _bgColor2 = c),
                        onClose: () => setState(() => _showBgPicker = false),
                      ),
                    ),

                  if (_showShapePicker)
                    Positioned(
                      top: 4,
                      left: 8,
                      child: ShapePickerPanel(
                        selected: _shapeType,
                        onSelect: (s) => setState(() {
                          _shapeType = s as ShapeType;
                          _tool = DrawingTool.shapes;
                          _showShapePicker = false;
                        }),
                        onClose: () => setState(() => _showShapePicker = false),
                      ),
                    ),

                  if (_showEmojiPicker)
                    Positioned(
                      top: 4,
                      left: 8,
                      right: 8,
                      child: EmojiPickerPanel(
                        onSelect: (emoji) => setState(() {
                          _addingEmoji = emoji;
                          _showEmojiPicker = false;
                        }),
                        onClose: () => setState(() => _showEmojiPicker = false),
                      ),
                    ),

                  if (_showLayerPanel)
                    Positioned(
                      top: 4,
                      right: 8,
                      child: LayerPanel(
                        layers: _layers,
                        activeIndex: _activeLayer,
                        onAdd: () => setState(() {
                          _layers.add('Layer ${_layers.length + 1}');
                          _activeLayer = _layers.length - 1;
                        }),
                        onSelect: (i) => setState(() => _activeLayer = i),
                        onClose: () => setState(() => _showLayerPanel = false),
                      ),
                    ),

                  if (_showImagePicker)
                    Positioned(
                      top: 4,
                      left: 8,
                      child: ImagePickerPanel(
                        onImageSelected: (file) {
                          setState(() {
                            _canvasItems.add(
                              CanvasItem(
                                type: CanvasItemType.image,
                                data: ImageItem(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                  file: file,
                                  position: const Offset(80, 150),
                                ),
                              ),
                            );
                            _showImagePicker = false;
                          });
                        },
                        onClose: () => setState(() => _showImagePicker = false),
                      ),
                    ),

                  if (_showTextInput)
                    Positioned(
                      bottom: 80,
                      left: 20,
                      right: 20,
                      child: TextInputBar(
                        onSubmit: _addText,
                        onCancel: () => setState(() => _showTextInput = false),
                        initialColor: _strokeColor,
                      ),
                    ),

                  if (_addingEmoji != null)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: kOrange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Tap canvas to place  $_addingEmoji',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      decoration: BoxDecoration(
        color: kOrange,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: kOrange.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          children: [
            _toolBtn(
              Icons.menu,
              'Menu',
              onTap: () => setState(() => _toolbarVisible = false),
            ),
            _toolBtn(Icons.undo, 'Undo', onTap: _undo),
            _toolBtn(Icons.redo, 'Redo', onTap: _redo),
            // Pen style
            _toolBtn(
              Icons.brush,
              'Pen Style',
              active: _showPenStylePicker,
              onTap: () => setState(() {
                _closeAllPanels();
                _showPenStylePicker = true;
                _tool = DrawingTool.pen;
              }),
            ),
            // Eraser
            _toolBtn(
              Icons.close,
              'Erase',
              active: _tool == DrawingTool.eraser,
              onTap: () => setState(() {
                _tool = _tool == DrawingTool.eraser
                    ? DrawingTool.pen
                    : DrawingTool.eraser;
              }),
            ),
            // Color
            _colorBtn(),
            // Width
            _toolBtn(
              Icons.line_weight,
              'Width',
              onTap: () => setState(() {
                _closeAllPanels();
                _showStrokeSlider = true;
              }),
            ),
            // Opacity
            _toolBtn(
              Icons.opacity,
              'Opacity',
              onTap: () => setState(() {
                _closeAllPanels();
                _showOpacitySlider = true;
              }),
            ),
            // Shapes
            _toolBtn(
              Icons.category_outlined,
              'Shapes',
              active: _tool == DrawingTool.shapes,
              onTap: () => setState(() {
                _closeAllPanels();
                _showShapePicker = true;
              }),
            ),
            // Emoji
            _toolBtn(
              Icons.emoji_emotions_outlined,
              'Emoji',
              onTap: () => setState(() {
                _closeAllPanels();
                _showEmojiPicker = true;
              }),
            ),
            // Text
            _toolBtn(
              Icons.text_fields,
              'Text',
              active: _tool == DrawingTool.text,
              onTap: () => setState(() {
                _tool = DrawingTool.text;
                _closeAllPanels();
              }),
            ),
            // Image
            _toolBtn(
              Icons.image_outlined,
              'Image',
              onTap: () => setState(() {
                _closeAllPanels();
                _showImagePicker = true;
              }),
            ),
            // Background
            _toolBtn(
              Icons.wallpaper,
              'Background',
              onTap: () => setState(() {
                _closeAllPanels();
                _showBgPicker = true;
              }),
            ),
            // Layers
            _toolBtn(
              Icons.layers_outlined,
              'Layers',
              onTap: () => setState(() {
                _closeAllPanels();
                _showLayerPanel = true;
              }),
            ),
            // Clear
            _toolBtn(Icons.delete_outline, 'Clear', onTap: _showClearDialog),
          ],
        ),
      ),
    );
  }

  Widget _toolBtn(
    IconData icon,
    String tooltip, {
    VoidCallback? onTap,
    bool active = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: active ? Colors.white.withOpacity(0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _colorBtn() {
    return GestureDetector(
      onTap: () => setState(() {
        _closeAllPanels();
        _showColorPicker = true;
        _tool = DrawingTool.pen;
      }),
      child: Container(
        width: 34,
        height: 34,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: _strokeColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}

// ── Pen style enum ────────────────────────────
enum PenStyle { pen, pencil, marker, spray }

// ── Opacity slider panel ──────────────────────
class _OpacitySlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final VoidCallback onClose;
  const _OpacitySlider({
    required this.value,
    required this.onChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.opacity, color: kOrange, size: 18),
          Expanded(
            child: Slider(
              value: value,
              min: 0.1,
              max: 1.0,
              activeColor: kOrange,
              inactiveColor: Colors.white24,
              onChanged: onChanged,
            ),
          ),
          Text(
            '${(value * 100).round()}%',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, color: Colors.grey, size: 16),
          ),
        ],
      ),
    );
  }
}

// ── Pen style picker panel ────────────────────
class _PenStylePicker extends StatelessWidget {
  final PenStyle selected;
  final ValueChanged<PenStyle> onSelect;
  final VoidCallback onClose;
  const _PenStylePicker({
    required this.selected,
    required this.onSelect,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    const styles = [
      (PenStyle.pen, Icons.edit, 'Pen'),
      (PenStyle.pencil, Icons.draw, 'Pencil'),
      (PenStyle.marker, Icons.brush, 'Marker'),
      (PenStyle.spray, Icons.blur_on, 'Spray'),
    ];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pen Style',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close, color: Colors.grey, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: styles.map((s) {
              final active = selected == s.$1;
              return GestureDetector(
                onTap: () => onSelect(s.$1),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: active ? kOrange : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        s.$2,
                        color: active ? Colors.white : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        s.$3,
                        style: TextStyle(
                          color: active ? Colors.white : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Background style picker ───────────────────
class _BgStylePicker extends StatelessWidget {
  final BgStyle selectedStyle;
  final Color color1;
  final Color color2;
  final ValueChanged<BgStyle> onStyleSelected;
  final ValueChanged<Color> onColor1Changed;
  final ValueChanged<Color> onColor2Changed;
  final VoidCallback onClose;

  const _BgStylePicker({
    required this.selectedStyle,
    required this.color1,
    required this.color2,
    required this.onStyleSelected,
    required this.onColor1Changed,
    required this.onColor2Changed,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    const styles = [
      (BgStyle.solid, 'Solid'),
      (BgStyle.linearGradient, 'Linear'),
      (BgStyle.radialGradient, 'Radial'),
      (BgStyle.dots, 'Dots'),
      (BgStyle.lines, 'Lines'),
      (BgStyle.grid, 'Grid'),
    ];

    final presets = [
      Colors.white,
      Colors.black,
      const Color(0xFF1a1a2e),
      const Color(0xFF16213e),
      const Color(0xFF0f3460),
      const Color(0xFFe94560),
      Colors.deepPurple,
      Colors.teal,
      Colors.orange,
      Colors.pink,
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Background',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close, color: Colors.grey, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Style chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: styles.map((s) {
                final active = selectedStyle == s.$1;
                return GestureDetector(
                  onTap: () => onStyleSelected(s.$1),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: active ? kOrange : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      s.$2,
                      style: TextStyle(
                        color: active ? Colors.white : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          // Color presets
          const Text(
            'Color 1',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: presets.map((c) {
                final active = color1 == c;
                return GestureDetector(
                  onTap: () => onColor1Changed(c),
                  child: Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: active ? kOrange : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Color 2',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: presets.map((c) {
                final active = color2 == c;
                return GestureDetector(
                  onTap: () => onColor2Changed(c),
                  child: Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: active ? kOrange : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Background pattern painters ───────────────
class _DotPatternPainter extends CustomPainter {
  final Color color;
  _DotPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.4);
    const spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPatternPainter old) => old.color != color;
}

class _LinePatternPainter extends CustomPainter {
  final Color color;
  _LinePatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 1;
    const spacing = 24.0;
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_LinePatternPainter old) => old.color != color;
}

class _GridPatternPainter extends CustomPainter {
  final Color color;
  _GridPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 1;
    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPatternPainter old) => old.color != color;
}
