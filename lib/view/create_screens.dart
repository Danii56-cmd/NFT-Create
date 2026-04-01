import 'package:flutter/material.dart';
import 'package:nft_create/enums.dart';
import 'package:nft_create/models/drawing_point.dart';
import 'package:nft_create/models/emoji_item.dart';
import 'package:nft_create/models/shape_item.dart';
import 'package:nft_create/models/text_item.dart';
import 'package:nft_create/painters/drawing_painters.dart';
import 'package:nft_create/widgets/nft_widgets/color_picker.dart';
import 'package:nft_create/widgets/nft_widgets/dragable_text.dart';
import 'package:nft_create/widgets/nft_widgets/draggable_emoji.dart';
import 'package:nft_create/widgets/nft_widgets/emoji_picker.dart';
import 'package:nft_create/widgets/nft_widgets/layer_panel.dart';
import 'package:nft_create/widgets/nft_widgets/shape_picker.dart';
import 'package:nft_create/widgets/nft_widgets/stroke_slider.dart';
import 'package:nft_create/widgets/nft_widgets/text_input_bar.dart';

const kOrange = Color(0xFFF5A623);
const kDark = Color(0xFF2A2A2A);
const kPanel = Color(0xFF1E1E1E);

class NFTCreatorScreen extends StatefulWidget {
  const NFTCreatorScreen({super.key});
  @override
  State<NFTCreatorScreen> createState() => _NFTCreatorScreenState();
}

class _NFTCreatorScreenState extends State<NFTCreatorScreen> {
  bool _toolbarVisible = false;

  List<List<DrawingPoint?>> _strokes = [];
  List<DrawingPoint?> _currentStroke = [];
  List<List<DrawingPoint?>> _undoStack = [];

  DrawingTool _tool = DrawingTool.pen;
  Color _strokeColor = Colors.black;
  double _strokeWidth = 4.0;
  bool _showColorPicker = false;
  bool _showStrokeSlider = false;
  bool _showShapePicker = false;
  bool _showEmojiPicker = false;
  bool _showLayerPanel = false;
  ShapeType _shapeType = ShapeType.rectangle;
  Color _bgColor = Colors.white;

  List<EmojiItem> _emojis = [];
  String? _addingEmoji;

  List<ShapeItem> _shapes = [];
  Offset? _shapeStart;

  final GlobalKey _canvasKey = GlobalKey();

  List<String> _layers = ['Layer 1'];
  int _activeLayer = 0;

  int _navIndex = 1;

  bool _showTextInput = false;
  Offset _textPosition = const Offset(100, 200);
  List<TextItem> _textItems = [];

  // ── Paint helper ──────────────────────────
  Paint _makePaint() {
    return Paint()
      ..color = _tool == DrawingTool.eraser ? _bgColor : _strokeColor
      ..strokeWidth = _tool == DrawingTool.eraser
          ? _strokeWidth * 4
          : _strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
  }

  // ── Gesture Handlers ──────────────────────
  void _handleTapDown(Offset position) {
    if (!_toolbarVisible) {
      setState(() => _toolbarVisible = true);
      return;
    }
    if (_addingEmoji != null) {
      setState(() {
        _emojis.add(EmojiItem(_addingEmoji!, position));
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
        if (_shapes.isNotEmpty && _shapes.last.isDrawing) {
          _shapes.last = ShapeItem(
            type: _shapeType,
            start: _shapeStart!,
            end: position,
            color: _strokeColor,
            strokeWidth: _strokeWidth,
            isDrawing: true,
          );
        } else {
          _shapes.add(
            ShapeItem(
              type: _shapeType,
              start: _shapeStart!,
              end: position,
              color: _strokeColor,
              strokeWidth: _strokeWidth,
              isDrawing: true,
            ),
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
        if (_shapes.isNotEmpty) {
          final last = _shapes.last;
          _shapes[_shapes.length - 1] = ShapeItem(
            type: last.type,
            start: last.start,
            end: last.end,
            color: last.color,
            strokeWidth: last.strokeWidth,
            isDrawing: false,
          );
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
      if (_shapes.isNotEmpty) {
        _undoStack.add([]);
        _shapes.removeLast();
      } else if (_strokes.isNotEmpty) {
        _undoStack.add(_strokes.removeLast());
      }
    });
  }

  void _redo() {
    setState(() {
      if (_undoStack.isNotEmpty) {
        _strokes.add(_undoStack.removeLast());
      }
    });
  }

  void _addText(String text, Color color, double size) {
    setState(() {
      _textItems.add(TextItem(text, _textPosition, color, size));
      _showTextInput = false;
    });
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
                _emojis.clear();
                _textItems.clear();
                _shapes.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDark,
      body: SafeArea(
        child: Column(
          children: [
            // ── Toolbar ──
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              height: _toolbarVisible ? 60 : 0,
              child: _toolbarVisible ? _buildToolbar() : const SizedBox(),
            ),
            // ── Canvas ──
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
                          color: _bgColor,
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
                              CustomPaint(
                                painter: DrawingPainter(
                                  strokes: _strokes,
                                  currentStroke: _currentStroke,
                                  shapes: _shapes,
                                ),
                                size: Size.infinite,
                              ),
                              ..._emojis.map(
                                (EmojiItem e) => DraggableEmoji(
                                  item: e,
                                  onMove: (pos) =>
                                      setState(() => e.position = pos),
                                  onDelete: () =>
                                      setState(() => _emojis.remove(e)),
                                ),
                              ),
                              ..._textItems.map(
                                (t) => DraggableText(
                                  item: t,
                                  onMove: (pos) =>
                                      setState(() => t.position = pos),
                                  onDelete: () =>
                                      setState(() => _textItems.remove(t)),
                                ),
                              ),
                              if (_strokes.isEmpty &&
                                  _emojis.isEmpty &&
                                  _textItems.isEmpty &&
                                  _shapes.isEmpty)
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _toolBtn(
            Icons.menu,
            'Menu',
            onTap: () => setState(() => _toolbarVisible = false),
          ),
          _toolBtn(Icons.undo, 'Undo', onTap: _undo),
          _toolBtn(Icons.redo, 'Redo', onTap: _redo),
          _toolBtn(
            Icons.category_outlined,
            'Shapes',
            active: _tool == DrawingTool.shapes,
            onTap: () => setState(() {
              _showShapePicker = !_showShapePicker;
              _showColorPicker = false;
              _showEmojiPicker = false;
              _showLayerPanel = false;
            }),
          ),
          _toolBtn(
            Icons.close,
            'Erase',
            active: _tool == DrawingTool.eraser,
            onTap: () => setState(() {
              _tool = _tool == DrawingTool.eraser
                  ? DrawingTool.pen
                  : DrawingTool.eraser;
              _showColorPicker = false;
            }),
          ),
          _colorBtn(),
          _toolBtn(
            Icons.line_weight,
            'Width',
            onTap: () => setState(() {
              _showStrokeSlider = !_showStrokeSlider;
              _showColorPicker = false;
              _showEmojiPicker = false;
              _showShapePicker = false;
            }),
          ),
          _toolBtn(
            Icons.emoji_emotions_outlined,
            'Emoji',
            onTap: () => setState(() {
              _showEmojiPicker = !_showEmojiPicker;
              _showColorPicker = false;
              _showShapePicker = false;
              _showLayerPanel = false;
            }),
          ),
          _toolBtn(
            Icons.text_fields,
            'Text',
            active: _tool == DrawingTool.text,
            onTap: () => setState(() {
              _tool = DrawingTool.text;
              _showColorPicker = false;
            }),
          ),
          _toolBtn(
            Icons.layers_outlined,
            'Layers',
            onTap: () => setState(() {
              _showLayerPanel = !_showLayerPanel;
              _showColorPicker = false;
              _showEmojiPicker = false;
              _showShapePicker = false;
            }),
          ),
          _toolBtn(Icons.delete_outline, 'Clear', onTap: _showClearDialog),
        ],
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
        _showColorPicker = !_showColorPicker;
        _showStrokeSlider = false;
        _showShapePicker = false;
        _showEmojiPicker = false;
        _showLayerPanel = false;
        _tool = DrawingTool.pen;
      }),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: _strokeColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}
