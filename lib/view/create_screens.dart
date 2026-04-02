// lib/view/nft_creator_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nft_create/enums.dart';
import 'package:nft_create/models/canvas_item.dart';
import 'package:nft_create/models/image_item.dart';
import 'package:nft_create/models/shape_item.dart';
import 'package:nft_create/models/text_item.dart';
import 'package:nft_create/models/emoji_item.dart';
import 'package:nft_create/providers/nft_creator_provider.dart';
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

class NFTCreatorScreen extends StatelessWidget {
  NFTCreatorScreen({super.key});

  final GlobalKey _canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NFTCreatorProvider>();

    return Scaffold(
      backgroundColor: kDark,
      body: SafeArea(
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              height: p.toolbarVisible ? 60 : 0,
              child: p.toolbarVisible
                  ? _buildToolbar(context, p)
                  : const SizedBox(),
            ),
            Expanded(
              child: Stack(
                children: [
                  GestureDetector(
                    onTapDown: (d) => p.handleTapDown(d.localPosition),
                    onPanStart: (d) => p.handlePanStart(d.localPosition),
                    onPanUpdate: (d) => p.handlePanUpdate(d.localPosition),
                    onPanEnd: (_) => p.handlePanEnd(),
                    child: RepaintBoundary(
                      key: _canvasKey,
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              // Background
                              Positioned.fill(
                                child: Container(
                                  decoration: p.bgDecoration,
                                  child: p.bgStyle == BgStyle.dots
                                      ? CustomPaint(
                                          painter: _DotPatternPainter(
                                            p.bgColor2,
                                          ),
                                        )
                                      : p.bgStyle == BgStyle.lines
                                      ? CustomPaint(
                                          painter: _LinePatternPainter(
                                            p.bgColor2,
                                          ),
                                        )
                                      : p.bgStyle == BgStyle.grid
                                      ? CustomPaint(
                                          painter: _GridPatternPainter(
                                            p.bgColor2,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              // Stroke painter
                              CustomPaint(
                                painter: DrawingPainter(
                                  strokes: p.strokes,
                                  currentStroke: p.currentStroke,
                                  shapes: const [],
                                ),
                                size: Size.infinite,
                              ),
                              // Canvas items
                              ..._buildCanvasItems(p),
                              // Empty state
                              if (p.isEmpty)
                                Center(
                                  child: GestureDetector(
                                    onTap: () => p.showToolbar(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            color: kOrange.withValues(
                                              alpha: 0.1,
                                            ),
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
                  if (p.showColorPicker)
                    Positioned(
                      top: 4,
                      left: 8,
                      child: ColorPickerPanel(
                        selectedColor: p.strokeColor,
                        bgColor: p.bgColor,
                        onColorSelected: (c) => p.setStrokeColor(c),
                        onBgColorSelected: (c) => p.setBgColor(c),
                        onClose: () => p.closeAllPanels(),
                      ),
                    ),

                  if (p.showStrokeSlider)
                    Positioned(
                      top: 4,
                      left: 8,
                      right: 8,
                      child: StrokeSlider(
                        value: p.strokeWidth,
                        onChanged: (v) => p.setStrokeWidth(v),
                        onClose: () => p.closeAllPanels(),
                      ),
                    ),

                  if (p.showOpacitySlider)
                    Positioned(
                      top: 4,
                      left: 8,
                      right: 8,
                      child: _OpacitySlider(
                        value: p.strokeOpacity,
                        onChanged: (v) => p.setStrokeOpacity(v),
                        onClose: () => p.closeAllPanels(),
                      ),
                    ),

                  if (p.showPenStylePicker)
                    Positioned(
                      top: 4,
                      left: 8,
                      child: _PenStylePicker(
                        selected: p.penStyle,
                        onSelect: (s) => p.setPenStyle(s),
                        onClose: () => p.closeAllPanels(),
                      ),
                    ),

                  if (p.showBgPicker)
                    Positioned(
                      top: 4,
                      left: 8,
                      right: 8,
                      child: _BgStylePicker(
                        selectedStyle: p.bgStyle,
                        color1: p.bgColor,
                        color2: p.bgColor2,
                        onStyleSelected: (s) => p.setBgStyle(s),
                        onColor1Changed: (c) => p.setBgColor(c),
                        onColor2Changed: (c) => p.setBgColor2(c),
                        onClose: () => p.closeAllPanels(),
                      ),
                    ),

                  if (p.showShapePicker)
                    Positioned(
                      top: 4,
                      left: 8,
                      child: ShapePickerPanel(
                        selected: p.shapeType,
                        onSelect: (s) => p.setShapeType(s),
                        onClose: () => p.closeAllPanels(),
                      ),
                    ),

                  if (p.showEmojiPicker)
                    Positioned(
                      top: 4,
                      left: 8,
                      right: 8,
                      child: EmojiPickerPanel(
                        onSelect: (emoji) => p.selectEmoji(emoji),
                        onClose: () => p.closeAllPanels(),
                      ),
                    ),

                  if (p.showLayerPanel)
                    Positioned(
                      top: 4,
                      right: 8,
                      child: LayerPanel(
                        layers: p.layers,
                        activeIndex: p.activeLayer,
                        onAdd: () => p.addLayer(),
                        onSelect: (i) => p.selectLayer(i),
                        onClose: () => p.closeAllPanels(),
                      ),
                    ),

                  if (p.showImagePicker)
                    Positioned(
                      top: 4,
                      left: 8,
                      child: ImagePickerPanel(
                        onImageSelected: (file) => p.addImage(file),
                        onClose: () => p.closeAllPanels(),
                      ),
                    ),

                  if (p.showTextInput)
                    Positioned(
                      bottom: 80,
                      left: 20,
                      right: 20,
                      child: TextInputBar(
                        onSubmit: (text, color, size) =>
                            p.addText(text, color, size),
                        onCancel: () => p.cancelText(),
                        initialColor: p.strokeColor,
                      ),
                    ),

                  if (p.addingEmoji != null)
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
                            'Tap canvas to place  ${p.addingEmoji}',
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

  List<Widget> _buildCanvasItems(NFTCreatorProvider p) {
    return p.canvasItems.map((ci) {
      switch (ci.type) {
        case CanvasItemType.image:
          final img = ci.data as ImageItem;
          return DraggableImage(
            key: ValueKey(img.id),
            item: img,
            locked: ci.locked,
            onMove: (pos) => p.moveItem(ci, pos),
            onScale: (s) => p.scaleImage(ci, s),
            onDelete: () => p.deleteItem(ci),
            onBringToFront: () => p.bringToFront(ci),
            onDuplicate: () => p.duplicate(ci),
            onToggleLock: () => p.toggleLock(ci),
            onFilterChanged: (filter) => p.setImageFilter(ci, filter),
          );
        case CanvasItemType.shape:
          final s = ci.data as ShapeItem;
          return DraggableShape(
            key: ValueKey(s.id),
            item: s,
            locked: ci.locked,
            onMove: (pos) => p.moveItem(ci, pos),
            onDelete: () => p.deleteItem(ci),
            onBringToFront: () => p.bringToFront(ci),
            onDuplicate: () => p.duplicate(ci),
            onToggleLock: () => p.toggleLock(ci),
          );
        case CanvasItemType.text:
          final t = ci.data as TextItem;
          return DraggableText(
            key: ValueKey(t.id),
            item: t,
            locked: ci.locked,
            onMove: (pos) => p.moveItem(ci, pos),
            onDelete: () => p.deleteItem(ci),
            onBringToFront: () => p.bringToFront(ci),
            onDuplicate: () => p.duplicate(ci),
            onToggleLock: () => p.toggleLock(ci),
          );
        case CanvasItemType.emoji:
          final e = ci.data as EmojiItem;
          return DraggableEmoji(
            key: ValueKey(e.id),
            item: e,
            locked: ci.locked,
            onMove: (pos) => p.moveItem(ci, pos),
            onDelete: () => p.deleteItem(ci),
            onBringToFront: () => p.bringToFront(ci),
            onDuplicate: () => p.duplicate(ci),
            onToggleLock: () => p.toggleLock(ci),
          );
      }
    }).toList();
  }

  Widget _buildToolbar(BuildContext context, NFTCreatorProvider p) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      decoration: BoxDecoration(
        color: kOrange,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: kOrange.withValues(alpha: 0.4),
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
            _toolBtn(Icons.menu, 'Menu', onTap: () => p.hideToolbar()),
            _toolBtn(Icons.undo, 'Undo', onTap: () => p.undo()),
            _toolBtn(Icons.redo, 'Redo', onTap: () => p.redo()),
            _toolBtn(
              Icons.brush,
              'Pen Style',
              active: p.showPenStylePicker,
              onTap: () => p.togglePenStylePicker(),
            ),
            _toolBtn(
              Icons.close,
              'Erase',
              active: p.tool == DrawingTool.eraser,
              onTap: () => p.setTool(
                p.tool == DrawingTool.eraser
                    ? DrawingTool.pen
                    : DrawingTool.eraser,
              ),
            ),
            // Color dot
            GestureDetector(
              onTap: () => p.toggleColorPicker(),
              child: Container(
                width: 34,
                height: 34,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: p.strokeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
            _toolBtn(
              Icons.line_weight,
              'Width',
              onTap: () => p.toggleStrokeSlider(),
            ),
            _toolBtn(
              Icons.opacity,
              'Opacity',
              onTap: () => p.toggleOpacitySlider(),
            ),
            _toolBtn(
              Icons.category_outlined,
              'Shapes',
              active: p.tool == DrawingTool.shapes,
              onTap: () => p.toggleShapePicker(),
            ),
            _toolBtn(
              Icons.emoji_emotions_outlined,
              'Emoji',
              onTap: () => p.toggleEmojiPicker(),
            ),
            _toolBtn(
              Icons.text_fields,
              'Text',
              active: p.tool == DrawingTool.text,
              onTap: () => p.setTool(DrawingTool.text),
            ),
            _toolBtn(
              Icons.image_outlined,
              'Image',
              onTap: () => p.toggleImagePicker(),
            ),
            _toolBtn(
              Icons.wallpaper,
              'Background',
              onTap: () => p.toggleBgPicker(),
            ),
            _toolBtn(
              Icons.layers_outlined,
              'Layers',
              onTap: () => p.toggleLayerPanel(),
            ),
            _toolBtn(
              Icons.delete_outline,
              'Clear',
              onTap: () => _showClearDialog(context, p),
            ),
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
            color: active
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context, NFTCreatorProvider p) {
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
              p.clearCanvas();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Opacity Slider ────────────────────────────
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

// ── Pen Style Picker ──────────────────────────
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
                    color: active
                        ? kOrange
                        : Colors.white.withValues(alpha: 0.1),
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

// ── Background Style Picker ───────────────────
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
                      color: active
                          ? kOrange
                          : Colors.white.withValues(alpha: 0.1),
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

// ── Pattern Painters ──────────────────────────
class _DotPatternPainter extends CustomPainter {
  final Color color;
  _DotPatternPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.4);
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
      ..color = color.withValues(alpha: 0.3)
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
      ..color = color.withValues(alpha: 0.3)
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
