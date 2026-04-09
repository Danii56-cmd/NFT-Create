import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:nft_create/services/auth_service.dart';
import 'package:nft_create/providers/nft_creator_provider.dart';
import 'package:nft_create/enums.dart';
import 'package:nft_create/models/canvas_item.dart';
import 'package:nft_create/models/image_item.dart';
import 'package:nft_create/models/shape_item.dart';
import 'package:nft_create/models/text_item.dart';
import 'package:nft_create/models/emoji_item.dart';
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

// ── Design tokens (const — zero allocation cost) ──────────────────────────────
const kOrange = Color(0xFFF5A623);
const kDark = Color(0xFF2A2A2A);
const kPanel = Color(0xFF1E1E1E);
const kOrangeOverlay = Color(0x1AF5A623);
const kBlackShadow = Color(0x4D000000);
const kWhite10 = Color(0x1AFFFFFF);
const kOrange40 = Color(0x66F5A623); // replaces kOrange.withOpacity(0.4)
const kOrange10 = Color(0x1AF5A623); // replaces kOrange.withOpacity(0.1)
const kWhite30 = Color(0x4DFFFFFF); // replaces Colors.white.withOpacity(0.3)
const kPanel90 = Color(0xE61E1E1E); // replaces kPanel.withOpacity(0.9)
const String hfToken = "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";

// ── Enums ─────────────────────────────────────────────────────────────────────
enum SymmetryMode { none, horizontal, vertical, quad }

enum TextEffect { none, shadow, outline, glow }

// ── Model ─────────────────────────────────────────────────────────────────────
class StyledTextData {
  final String text;
  final Color color;
  final double fontSize;
  final TextEffect effect;
  final Color effectColor;
  final FontWeight fontWeight;
  const StyledTextData({
    required this.text,
    required this.color,
    this.fontSize = 28,
    this.effect = TextEffect.none,
    this.effectColor = Colors.black,
    this.fontWeight = FontWeight.bold,
  });
}

// ══════════════════════════════════════════════════════════════════════════════
// NFTCreatorScreen
// ══════════════════════════════════════════════════════════════════════════════
class NFTCreatorScreen extends StatefulWidget {
  const NFTCreatorScreen({super.key});
  @override
  State<NFTCreatorScreen> createState() => _NFTCreatorScreenState();
}

class _NFTCreatorScreenState extends State<NFTCreatorScreen> {
  final GlobalKey _canvasKey = GlobalKey();

  // ── Zoom state ────────────────────────────────────────────────────────────
  double _scale = 1.0;
  double _prevScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _focalStart = Offset.zero;
  Offset _offsetStart = Offset.zero;
  bool _isZooming = false;
  bool _zoomEnabled = false;
  static const double _minScale = 0.5;
  static const double _maxScale = 5.0;
  bool _isGenerating = false; // ← Add this line
  // Cached transform — only rebuilt when scale/offset actually change
  Matrix4 _transform = Matrix4.identity();
  void _rebuildTransform() {
    _transform = Matrix4.identity()
      ..translate(_offset.dx, _offset.dy)
      ..scale(_scale);
  }

  // ── Creative tools state ──────────────────────────────────────────────────
  SymmetryMode _symmetryMode = SymmetryMode.none;
  double _noiseIntensity = 0.0;
  BlendMode _blendMode = BlendMode.srcOver;
  bool _showStickerPicker = false;
  bool _showTextEffectsPicker = false;
  bool _showSymmetryPanel = false;
  bool _showNoisePanel = false;
  bool _showBlendModePanel = false;
  final List<StyledTextData> _styledTexts = [];

  void _closeNewPanels() => setState(() {
    _showStickerPicker = false;
    _showTextEffectsPicker = false;
    _showSymmetryPanel = false;
    _showNoisePanel = false;
    _showBlendModePanel = false;
  });

  void _onlyOpen(String panel) => setState(() {
    _showStickerPicker = panel == 'sticker';
    _showTextEffectsPicker = panel == 'textfx';
    _showSymmetryPanel = panel == 'symmetry';
    _showNoisePanel = panel == 'noise';
    _showBlendModePanel = panel == 'blend';
  });

  void _resetZoom() => setState(() {
    _scale = 1.0;
    _offset = Offset.zero;
    _rebuildTransform();
  });

  Offset _toCanvas(Offset screen) => (screen - _offset) / _scale;

  // ── Gesture handlers (extracted to avoid lambda allocations in build) ─────
  late final NFTCreatorProvider _provider;
  bool _providerCached = false;

  NFTCreatorProvider get _p {
    if (!_providerCached) {
      _provider = context.read<NFTCreatorProvider>();
      _providerCached = true;
    }
    return _provider;
  }

  void _onTapDown(TapDownDetails d) =>
      _p.handleTapDown(_toCanvas(d.localPosition));

  void _onScaleStart(ScaleStartDetails d) {
    _prevScale = _scale;
    _focalStart = d.focalPoint;
    _offsetStart = _offset;
    _isZooming = d.pointerCount >= 2;
    if (d.pointerCount == 1) _p.handlePanStart(_toCanvas(d.localFocalPoint));
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    if (d.pointerCount >= 2 && _zoomEnabled) {
      setState(() {
        _scale = (_prevScale * d.scale).clamp(_minScale, _maxScale);
        _offset = _offsetStart + (d.focalPoint - _focalStart);
        _rebuildTransform();
      });
      _isZooming = true;
    } else if (d.pointerCount == 1 && !_isZooming) {
      _p.handlePanUpdate(_toCanvas(d.localFocalPoint));
    }
  }

  void _onScaleEnd(ScaleEndDetails d) {
    if (!_isZooming) _p.handlePanEnd();
    _isZooming = false;
  }

  Future<void> _generateWithAI() async {
    final promptController = TextEditingController();
    final prompt = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF333333),
        title: const Text(
          'Generate with AI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: promptController,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    "A cute cyberpunk cat in neon city, NFT style, highly detailed",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kOrange),
            onPressed: () => Navigator.pop(ctx, promptController.text.trim()),
            child: const Text(
              'Generate',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (prompt == null || prompt.isEmpty) return;

    setState(() => _isGenerating = true);

    try {
      final response = await http.post(
        Uri.parse(
          'https://router.huggingface.co/hf-inference/models/black-forest-labs/FLUX.1-schnell',
        ),
        headers: {
          'Authorization': 'Bearer $hfToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "inputs": prompt,
          "parameters": {
            "num_inference_steps": 4,
            "guidance_scale": 3.5,
            "width": 512,
            "height": 512,
          },
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Content-Type: ${response.headers['content-type']}");
      print("Response Length: ${response.bodyBytes.length} bytes");

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        // Check if it's actually an image
        final contentType =
            response.headers['content-type']?.toLowerCase() ?? '';
        final isImage =
            contentType.contains('image/') ||
            (bytes.length > 100 &&
                ((bytes[0] == 0x89 &&
                        bytes[1] == 0x50 &&
                        bytes[2] == 0x4E &&
                        bytes[3] == 0x47) || // PNG
                    (bytes[0] == 0xFF && bytes[1] == 0xD8))); // JPEG

        if (!isImage) {
          // Try to show the actual error
          String errorMsg = "Unknown error";
          try {
            final json = jsonDecode(utf8.decode(bytes));
            errorMsg = json.toString();
          } catch (_) {
            errorMsg = utf8.decode(bytes.take(300).toList());
          }
          throw Exception('Not an image! Received: $errorMsg');
        }

        // Valid image
        context.read<NFTCreatorProvider>().addImageFromBytes(
          bytes,
          "AI_${DateTime.now().millisecondsSinceEpoch}",
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: kOrange,
              content: Text('✅ AI Image added successfully!'),
            ),
          );
        }
      } else {
        String msg = 'HTTP ${response.statusCode}';
        try {
          final err = jsonDecode(utf8.decode(response.bodyBytes));
          msg = err['error']?.toString() ?? msg;
        } catch (_) {}
        throw Exception(msg);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
      print("Full error: $e");
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDark,
      body: SafeArea(
        child: Column(
          children: [
            // ── Toolbar — only rebuilds for toolbar-relevant fields ────────
            Selector<NFTCreatorProvider, _ToolbarData>(
              selector: (_, p) => _ToolbarData(
                visible: p.toolbarVisible,
                tool: p.tool,
                strokeColor: p.strokeColor,
                showPenStyle: p.showPenStylePicker,
              ),
              shouldRebuild: (a, b) => a != b,
              builder: (ctx, data, __) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                height: data.visible ? 60 : 0,
                child: data.visible
                    ? _buildToolbar(ctx, context.read<NFTCreatorProvider>())
                    : const SizedBox.shrink(),
              ),
            ),

            // ── Canvas ───────────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  GestureDetector(
                    onTapDown: _onTapDown,
                    onScaleStart: _onScaleStart,
                    onScaleUpdate: _onScaleUpdate,
                    onScaleEnd: _onScaleEnd,
                    child: Transform(
                      transform: _transform,
                      child: RepaintBoundary(
                        key: _canvasKey,
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            boxShadow: [
                              BoxShadow(color: kBlackShadow, blurRadius: 20),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(16),
                            ),
                            child: _CanvasContent(
                              symmetryMode: _symmetryMode,
                              noiseIntensity: _noiseIntensity,
                              styledTexts: _styledTexts,
                              onDeleteStyled: (i) =>
                                  setState(() => _styledTexts.removeAt(i)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Floating panels ───────────────────────────────────
                  _FloatingPanels(
                    onDeleteStyled: (i) =>
                        setState(() => _styledTexts.removeAt(i)),
                  ),

                  // ── New panels ────────────────────────────────────────
                  if (_showStickerPicker)
                    Positioned(
                      top: 4,
                      left: 8,
                      child: _StickerPickerPanel(
                        onSelect: (s) {
                          context.read<NFTCreatorProvider>().selectEmoji(s);
                          _closeNewPanels();
                        },
                        onClose: _closeNewPanels,
                      ),
                    ),
                  if (_showTextEffectsPicker)
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: _TextEffectsInputBar(
                        initialColor: context
                            .read<NFTCreatorProvider>()
                            .strokeColor,
                        onSubmit: (style) {
                          setState(() => _styledTexts.add(style));
                          _closeNewPanels();
                        },
                        onCancel: _closeNewPanels,
                      ),
                    ),
                  if (_showSymmetryPanel)
                    Positioned(
                      top: 4,
                      left: 8,
                      child: _SymmetryToolbar(
                        current: _symmetryMode,
                        onChanged: (m) => setState(() => _symmetryMode = m),
                        onClose: _closeNewPanels,
                      ),
                    ),
                  if (_showNoisePanel)
                    Positioned(
                      top: 4,
                      left: 8,
                      right: 8,
                      child: _NoiseOverlayPanel(
                        intensity: _noiseIntensity,
                        onChanged: (v) => setState(() => _noiseIntensity = v),
                        onClose: _closeNewPanels,
                      ),
                    ),
                  if (_showBlendModePanel)
                    Positioned(
                      top: 4,
                      right: 8,
                      child: _BlendModePanel(
                        selected: _blendMode,
                        onSelect: (m) => setState(() => _blendMode = m),
                        onClose: _closeNewPanels,
                      ),
                    ),

                  // ── Zoom badge ────────────────────────────────────────
                  Positioned(
                    bottom: 12,
                    right: 16,
                    child: _ZoomBadge(
                      scale: _scale,
                      zoomEnabled: _zoomEnabled,
                      onToggle: () {
                        setState(() => _zoomEnabled = !_zoomEnabled);
                        if (!_zoomEnabled) _resetZoom();
                      },
                      onReset: _resetZoom,
                    ),
                  ), // AI Loading Overlay
                  if (_isGenerating)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: kOrange),
                            SizedBox(height: 16),
                            Text(
                              'Generating AI Image...\nPlease wait',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
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

  // ── Toolbar ───────────────────────────────────────────────────────────────
  Widget _buildToolbar(BuildContext ctx, NFTCreatorProvider p) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      decoration: const BoxDecoration(
        color: kOrange,
        borderRadius: BorderRadius.all(Radius.circular(14)),
        boxShadow: [
          BoxShadow(color: kOrange40, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          children: [
            _toolBtn(Icons.menu, 'Menu', onTap: p.hideToolbar),
            _toolBtn(Icons.undo, 'Undo', onTap: p.undo),
            _toolBtn(Icons.redo, 'Redo', onTap: p.redo),
            _toolBtn(
              Icons.brush,
              'Pen Style',
              active: p.showPenStylePicker,
              onTap: p.togglePenStylePicker,
            ),
            _toolBtn(Icons.save_alt, 'Save', onTap: () => _saveToGallery(ctx)),
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
            // Colour swatch
            GestureDetector(
              onTap: p.toggleColorPicker,
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
            _toolBtn(Icons.line_weight, 'Width', onTap: p.toggleStrokeSlider),
            _toolBtn(Icons.opacity, 'Opacity', onTap: p.toggleOpacitySlider),
            _toolBtn(
              Icons.category_outlined,
              'Shapes',
              active: p.tool == DrawingTool.shapes,
              onTap: p.toggleShapePicker,
            ),
            _toolBtn(
              Icons.emoji_emotions_outlined,
              'Emoji',
              onTap: p.toggleEmojiPicker,
            ),
            _toolBtn(
              Icons.text_fields,
              'Text',
              active: p.tool == DrawingTool.text,
              onTap: () => p.setTool(DrawingTool.text),
            ),
            _toolBtn(Icons.image_outlined, 'Image', onTap: p.toggleImagePicker),
            _toolBtn(Icons.wallpaper, 'Background', onTap: p.toggleBgPicker),
            _toolBtn(
              Icons.layers_outlined,
              'Layers',
              onTap: p.toggleLayerPanel,
            ),
            _toolBtn(
              Icons.delete_outline,
              'Clear',
              onTap: () => _showClearDialog(ctx, p),
            ),
            _toolBtn(
              Icons.sticky_note_2_outlined,
              'Stickers',
              active: _showStickerPicker,
              onTap: () {
                p.closeAllPanels();
                _onlyOpen(_showStickerPicker ? '' : 'sticker');
              },
            ),
            _toolBtn(
              Icons.text_format,
              'Text FX',
              active: _showTextEffectsPicker,
              onTap: () {
                p.closeAllPanels();
                _onlyOpen(_showTextEffectsPicker ? '' : 'textfx');
              },
            ),
            _toolBtn(
              Icons.flip,
              'Symmetry',
              active: _symmetryMode != SymmetryMode.none || _showSymmetryPanel,
              onTap: () {
                p.closeAllPanels();
                _onlyOpen(_showSymmetryPanel ? '' : 'symmetry');
              },
            ),
            _toolBtn(
              Icons.grain,
              'Grain',
              active: _noiseIntensity > 0 || _showNoisePanel,
              onTap: () {
                p.closeAllPanels();
                _onlyOpen(_showNoisePanel ? '' : 'noise');
              },
            ),
            _toolBtn(
              Icons.layers_clear,
              'Blend Mode',
              active: _blendMode != BlendMode.srcOver || _showBlendModePanel,
              onTap: () {
                p.closeAllPanels();
                _onlyOpen(_showBlendModePanel ? '' : 'blend');
              },
            ),
            _toolBtn(
              Icons.auto_awesome,
              'Generate with AI',
              onTap: _generateWithAI,
            ),
            _toolBtn(
              Icons.zoom_in,
              'Zoom',
              active: _zoomEnabled,
              onTap: () {
                setState(() => _zoomEnabled = !_zoomEnabled);
                if (!_zoomEnabled) _resetZoom();
              },
            ),
          ],
        ),
      ),
    );
  }

  static Widget _toolBtn(
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
            color: active ? kWhite30 : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Future<void> _saveToGallery(BuildContext context) async {
    final result = await _showNftInfoDialog(context);
    if (result == null) return;
    try {
      final boundary =
          _canvasKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      await Gal.putImageBytes(
        bytes,
        name: 'nft_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      final userId = await AuthService().getCurrentUserId() ?? 'guest';
      final box = await Hive.openBox('nfts_$userId');
      await box.put(DateTime.now().millisecondsSinceEpoch.toString(), {
        'bytes': bytes,
        'date': DateTime.now().toIso8601String(),
        'title': result['title'],
        'description': result['description'],
        'price': result['price'],
        'creator': result['creator'],
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: kOrange,
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'NFT saved successfully!',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Map<String, String>?> _showNftInfoDialog(BuildContext context) {
    final titleC = TextEditingController();
    final descC = TextEditingController();
    final priceC = TextEditingController();
    final creatorC = TextEditingController();
    return showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF333333),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        title: const Text(
          '🎨 Save NFT',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(titleC, 'NFT Title *', Icons.title),
              const SizedBox(height: 12),
              _dialogField(
                descC,
                'Description',
                Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              _dialogField(
                priceC,
                'Price (e.g. 0.5 ETH)',
                Icons.attach_money,
                inputType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _dialogField(creatorC, 'Your Name', Icons.person),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kOrange,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            onPressed: () {
              if (titleC.text.trim().isEmpty) return;
              Navigator.pop(ctx, {
                'title': titleC.text.trim(),
                'description': descC.text.trim(),
                'price': priceC.text.trim(),
                'creator': creatorC.text.trim(),
              });
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static Widget _dialogField(
    TextEditingController c,
    String hint,
    IconData icon, {
    int maxLines = 1,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: kOrange, size: 18),
        filled: true,
        fillColor: Colors.white10,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide.none,
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
              setState(() => _styledTexts.clear());
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Selector data class for toolbar ──────────────────────────────────────────
class _ToolbarData {
  final bool visible;
  final DrawingTool tool;
  final Color strokeColor;
  final bool showPenStyle;
  const _ToolbarData({
    required this.visible,
    required this.tool,
    required this.strokeColor,
    required this.showPenStyle,
  });
  @override
  bool operator ==(Object o) =>
      o is _ToolbarData &&
      o.visible == visible &&
      o.tool == tool &&
      o.strokeColor == strokeColor &&
      o.showPenStyle == showPenStyle;
  @override
  int get hashCode => Object.hash(visible, tool, strokeColor, showPenStyle);
}

// ══════════════════════════════════════════════════════════════════════════════
// _CanvasContent — isolated subtree so only canvas-relevant state causes repaints
// ══════════════════════════════════════════════════════════════════════════════
class _CanvasContent extends StatelessWidget {
  final SymmetryMode symmetryMode;
  final double noiseIntensity;
  final List<StyledTextData> styledTexts;
  final void Function(int) onDeleteStyled;

  const _CanvasContent({
    required this.symmetryMode,
    required this.noiseIntensity,
    required this.styledTexts,
    required this.onDeleteStyled,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NFTCreatorProvider>();
    return Stack(
      children: [
        // Background
        Positioned.fill(
          child: RepaintBoundary(
            child: Container(
              decoration: p.bgDecoration,
              child: _buildBgPattern(p),
            ),
          ),
        ),

        // Drawing strokes — wrapped in its own RepaintBoundary
        RepaintBoundary(
          child: CustomPaint(
            painter: DrawingPainter(
              strokes: p.strokes,
              currentStroke: p.currentStroke,
              shapes: const [],
            ),
            size: Size.infinite,
          ),
        ),

        // Canvas items
        ..._buildCanvasItems(context, p),

        // Styled text
        ...List.generate(
          styledTexts.length,
          (i) => _DraggableStyledText(
            key: ValueKey('styled_$i'),
            style: styledTexts[i],
            initialPosition: Offset(80 + i * 12.0, 120 + i * 12.0),
            onDelete: () => onDeleteStyled(i),
          ),
        ),

        // Symmetry guide — wrapped so it doesn't invalidate stroke layer
        if (symmetryMode != SymmetryMode.none)
          RepaintBoundary(
            child: CustomPaint(
              painter: _SymmetryGuidePainter(symmetryMode),
              size: Size.infinite,
            ),
          ),

        // Noise overlay — wrapped so slider drags don't repaint everything
        if (noiseIntensity > 0)
          RepaintBoundary(
            child: CustomPaint(
              painter: _NoisePainter(intensity: noiseIntensity, seed: 42),
              size: Size.infinite,
            ),
          ),

        // Empty state
        if (p.isEmpty && styledTexts.isEmpty)
          Center(
            child: GestureDetector(
              onTap: p.showToolbar,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _EmptyStateIcon(),
                  SizedBox(height: 12),
                  Text(
                    'Tap to start creating',
                    style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  static Widget _buildBgPattern(NFTCreatorProvider p) {
    if (p.bgStyle == BgStyle.dots)
      return CustomPaint(painter: _DotPatternPainter(p.bgColor2));
    if (p.bgStyle == BgStyle.lines)
      return CustomPaint(painter: _LinePatternPainter(p.bgColor2));
    if (p.bgStyle == BgStyle.grid)
      return CustomPaint(painter: _GridPatternPainter(p.bgColor2));
    return const SizedBox.shrink();
  }

  static List<Widget> _buildCanvasItems(
    BuildContext context,
    NFTCreatorProvider p,
  ) {
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
            onFilterChanged: (f) => p.setImageFilter(ci, f),
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
        default:
          return const SizedBox.shrink();
      }
    }).toList();
  }
}

// Extracted const widget — avoids re-instantiation on every build
class _EmptyStateIcon extends StatelessWidget {
  const _EmptyStateIcon();
  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 64,
    height: 64,
    child: DecoratedBox(
      decoration: BoxDecoration(color: kOrangeOverlay, shape: BoxShape.circle),
      child: Icon(Icons.palette_outlined, color: kOrange, size: 36),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// _FloatingPanels — consumes provider only for the panels it needs
// ══════════════════════════════════════════════════════════════════════════════
class _FloatingPanels extends StatelessWidget {
  final void Function(int) onDeleteStyled;
  const _FloatingPanels({required this.onDeleteStyled});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NFTCreatorProvider>();
    return Stack(
      children: [
        if (p.showColorPicker)
          Positioned(
            top: 4,
            left: 8,
            child: ColorPickerPanel(
              selectedColor: p.strokeColor,
              bgColor: p.bgColor,
              onColorSelected: (c) => p.setStrokeColor(c),
              onBgColorSelected: (c) => p.setBgColor(c),
              onClose: p.closeAllPanels,
            ),
          ),
        if (p.showStrokeSlider)
          Positioned(
            top: 4,
            left: 8,
            right: 8,
            child: StrokeSlider(
              value: p.strokeWidth,
              onChanged: p.setStrokeWidth,
              onClose: p.closeAllPanels,
            ),
          ),
        if (p.showOpacitySlider)
          Positioned(
            top: 4,
            left: 8,
            right: 8,
            child: _OpacitySlider(
              value: p.strokeOpacity,
              onChanged: p.setStrokeOpacity,
              onClose: p.closeAllPanels,
            ),
          ),
        if (p.showPenStylePicker)
          Positioned(
            top: 4,
            left: 8,
            child: _PenStylePicker(
              selected: p.penStyle,
              onSelect: p.setPenStyle,
              onClose: p.closeAllPanels,
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
              onStyleSelected: p.setBgStyle,
              onColor1Changed: p.setBgColor,
              onColor2Changed: p.setBgColor2,
              onClose: p.closeAllPanels,
            ),
          ),
        if (p.showShapePicker)
          Positioned(
            top: 4,
            left: 8,
            child: ShapePickerPanel(
              selected: p.shapeType,
              onSelect: p.setShapeType,
              onClose: p.closeAllPanels,
            ),
          ),
        if (p.showEmojiPicker)
          Positioned(
            top: 4,
            left: 8,
            right: 8,
            child: EmojiPickerPanel(
              onSelect: p.selectEmoji,
              onClose: p.closeAllPanels,
            ),
          ),
        if (p.showLayerPanel)
          Positioned(
            top: 4,
            right: 8,
            child: LayerPanel(
              layers: p.layers,
              activeIndex: p.activeLayer,
              onAdd: p.addLayer,
              onSelect: p.selectLayer,
              onClose: p.closeAllPanels,
            ),
          ),
        if (p.showImagePicker)
          Positioned(
            top: 4,
            left: 8,
            child: ImagePickerPanel(
              onImageSelected: p.addImage,
              onClose: p.closeAllPanels,
            ),
          ),
        if (p.showTextInput)
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: TextInputBar(
              onSubmit: p.addText,
              onCancel: p.cancelText,
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
                decoration: const BoxDecoration(
                  color: kOrange,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Text(
                  'Tap canvas to place ${p.addingEmoji}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Zoom badge extracted to avoid rebuilding the full stack on scale change ───
class _ZoomBadge extends StatelessWidget {
  final double scale;
  final bool zoomEnabled;
  final VoidCallback onToggle;
  final VoidCallback onReset;
  const _ZoomBadge({
    required this.scale,
    required this.zoomEnabled,
    required this.onToggle,
    required this.onReset,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: kPanel90,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          border: Border.all(
            color: zoomEnabled ? kOrange : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              zoomEnabled ? Icons.zoom_in : Icons.zoom_out_map,
              color: zoomEnabled ? kOrange : Colors.grey,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              zoomEnabled ? '${(scale * 100).round()}%' : 'Zoom',
              style: TextStyle(
                color: zoomEnabled ? kOrange : Colors.grey,
                fontSize: 11,
              ),
            ),
            if (zoomEnabled && scale != 1.0) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onReset,
                child: const Icon(
                  Icons.center_focus_strong,
                  color: Colors.grey,
                  size: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Original helper widgets
// ══════════════════════════════════════════════════════════════════════════════

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
      decoration: const BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.all(Radius.circular(14)),
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

class _PenStylePicker extends StatelessWidget {
  final PenStyle selected;
  final ValueChanged<PenStyle> onSelect;
  final VoidCallback onClose;
  const _PenStylePicker({
    required this.selected,
    required this.onSelect,
    required this.onClose,
  });
  static const _styles = [
    (PenStyle.pen, Icons.edit, 'Pen'),
    (PenStyle.pencil, Icons.draw, 'Pencil'),
    (PenStyle.marker, Icons.brush, 'Marker'),
    (PenStyle.spray, Icons.blur_on, 'Spray'),
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.all(Radius.circular(14)),
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
            children: _styles.map((s) {
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
                    color: active ? kOrange : kWhite10,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
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

class _BgStylePicker extends StatelessWidget {
  final BgStyle selectedStyle;
  final Color color1, color2;
  final ValueChanged<BgStyle> onStyleSelected;
  final ValueChanged<Color> onColor1Changed, onColor2Changed;
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
  static const _styles = [
    (BgStyle.solid, 'Solid'),
    (BgStyle.linearGradient, 'Linear'),
    (BgStyle.radialGradient, 'Radial'),
    (BgStyle.dots, 'Dots'),
    (BgStyle.lines, 'Lines'),
    (BgStyle.grid, 'Grid'),
  ];
  static const _presets = [
    Colors.white,
    Colors.black,
    Color(0xFF1a1a2e),
    Color(0xFF16213e),
    Color(0xFF0f3460),
    Color(0xFFe94560),
    Colors.deepPurple,
    Colors.teal,
    Colors.orange,
    Colors.pink,
  ];
  Widget _swatches(Color sel, ValueChanged<Color> onSel) =>
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _presets.map((c) {
            final active = sel == c;
            return GestureDetector(
              onTap: () => onSel(c),
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
      );
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.all(Radius.circular(14)),
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
              children: _styles.map((s) {
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
                      color: active ? kOrange : kWhite10,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
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
          _swatches(color1, onColor1Changed),
          const SizedBox(height: 8),
          const Text(
            'Color 2',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 6),
          _swatches(color2, onColor2Changed),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Pattern painters
// ══════════════════════════════════════════════════════════════════════════════
class _DotPatternPainter extends CustomPainter {
  final Color color;
  const _DotPatternPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Color.fromARGB(
        (color.alpha * 0.4).round(),
        color.red,
        color.green,
        color.blue,
      );
    const s = 20.0;
    for (double x = 0; x < size.width; x += s)
      for (double y = 0; y < size.height; y += s)
        canvas.drawCircle(Offset(x, y), 1.5, p);
  }

  @override
  bool shouldRepaint(_DotPatternPainter o) => o.color != color;
}

class _LinePatternPainter extends CustomPainter {
  final Color color;
  const _LinePatternPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Color.fromARGB(
        (color.alpha * 0.3).round(),
        color.red,
        color.green,
        color.blue,
      )
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 24)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }

  @override
  bool shouldRepaint(_LinePatternPainter o) => o.color != color;
}

class _GridPatternPainter extends CustomPainter {
  final Color color;
  const _GridPatternPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Color.fromARGB(
        (color.alpha * 0.3).round(),
        color.red,
        color.green,
        color.blue,
      )
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 24)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += 24)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }

  @override
  bool shouldRepaint(_GridPatternPainter o) => o.color != color;
}

// ══════════════════════════════════════════════════════════════════════════════
// New creative widgets
// ══════════════════════════════════════════════════════════════════════════════

class _StickerPackData {
  final String name;
  final IconData icon;
  final List<String> stickers;
  const _StickerPackData(this.name, this.icon, this.stickers);
}

class _StickerPickerPanel extends StatefulWidget {
  final ValueChanged<String> onSelect;
  final VoidCallback onClose;
  const _StickerPickerPanel({required this.onSelect, required this.onClose});
  @override
  State<_StickerPickerPanel> createState() => _StickerPickerPanelState();
}

class _StickerPickerPanelState extends State<_StickerPickerPanel> {
  int _pack = 0;
  static const _packs = [
    _StickerPackData('Crypto', Icons.currency_bitcoin, [
      '₿',
      '⟠',
      '◎',
      '⬡',
      '🪙',
      '💎',
      '🚀',
      '🌕',
      '📈',
      '💰',
      '🏦',
      '⚡',
    ]),
    _StickerPackData('Abstract', Icons.auto_awesome, [
      '✦',
      '✧',
      '◈',
      '⬟',
      '⟐',
      '❋',
      '✺',
      '⊹',
      '✶',
      '⁂',
      '❃',
      '⌘',
    ]),
    _StickerPackData('Nature', Icons.eco, [
      '🌊',
      '🔥',
      '⚡',
      '🌪️',
      '❄️',
      '🌸',
      '🍄',
      '🌙',
      '⭐',
      '🌈',
      '🦋',
      '🐉',
    ]),
    _StickerPackData('Art', Icons.palette, [
      '🎨',
      '🖌️',
      '✏️',
      '🖼️',
      '🎭',
      '🎪',
      '🎬',
      '📸',
      '🎵',
      '🎸',
      '🎤',
      '🏆',
    ]),
    _StickerPackData('Faces', Icons.emoji_emotions, [
      '😈',
      '👾',
      '🤖',
      '👽',
      '💀',
      '🎃',
      '🦊',
      '🐺',
      '🦁',
      '🐯',
      '🦅',
      '🦋',
    ]),
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.all(Radius.circular(14)),
        boxShadow: [BoxShadow(color: Color(0x44000000), blurRadius: 12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Stickers',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: widget.onClose,
                child: const Icon(Icons.close, color: Colors.grey, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_packs.length, (i) {
                final active = _pack == i;
                return GestureDetector(
                  onTap: () => setState(() => _pack = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: active ? kOrange : kWhite10,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _packs[i].icon,
                          size: 13,
                          color: active ? Colors.white : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _packs[i].name,
                          style: TextStyle(
                            fontSize: 12,
                            color: active ? Colors.white : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: _packs[_pack].stickers
                .map(
                  (s) => GestureDetector(
                    onTap: () => widget.onSelect(s),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: kWhite10,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Center(
                        child: Text(s, style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TextEffectsInputBar extends StatefulWidget {
  final void Function(StyledTextData) onSubmit;
  final VoidCallback onCancel;
  final Color initialColor;
  const _TextEffectsInputBar({
    required this.onSubmit,
    required this.onCancel,
    required this.initialColor,
  });
  @override
  State<_TextEffectsInputBar> createState() => _TextEffectsInputBarState();
}

class _TextEffectsInputBarState extends State<_TextEffectsInputBar> {
  final _ctrl = TextEditingController();
  late Color _color;
  double _size = 28;
  TextEffect _fx = TextEffect.none;
  Color _fxColor = Colors.black;

  static const _textColors = [
    Colors.white,
    Colors.black,
    kOrange,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.pink,
  ];
  static const _fxColors = [
    Colors.black,
    Colors.white,
    kOrange,
    Colors.red,
    Colors.blue,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    _color = widget.initialColor;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _chip(String label, bool active, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: active ? kOrange : kWhite10,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [BoxShadow(color: Color(0x55000000), blurRadius: 16)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _ctrl,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter text...',
              hintStyle: TextStyle(color: Colors.grey),
              filled: true,
              fillColor: kWhite10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'Size ',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Expanded(
                child: Slider(
                  value: _size,
                  min: 12,
                  max: 80,
                  activeColor: kOrange,
                  inactiveColor: kWhite10,
                  onChanged: (v) => setState(() => _size = v),
                ),
              ),
              Text(
                '${_size.round()}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          const Text(
            'Color',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _textColors
                  .map(
                    (c) => GestureDetector(
                      onTap: () => setState(() => _color = c),
                      child: Container(
                        width: 26,
                        height: 26,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _color == c ? kOrange : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Effect',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _chip(
                'None',
                _fx == TextEffect.none,
                () => setState(() => _fx = TextEffect.none),
              ),
              _chip(
                'Shadow',
                _fx == TextEffect.shadow,
                () => setState(() => _fx = TextEffect.shadow),
              ),
              _chip(
                'Outline',
                _fx == TextEffect.outline,
                () => setState(() => _fx = TextEffect.outline),
              ),
              _chip(
                'Glow',
                _fx == TextEffect.glow,
                () => setState(() => _fx = TextEffect.glow),
              ),
            ],
          ),
          if (_fx != TextEffect.none) ...[
            const SizedBox(height: 8),
            const Text(
              'Effect color',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _fxColors
                    .map(
                      (c) => GestureDetector(
                        onTap: () => setState(() => _fxColor = c),
                        child: Container(
                          width: 26,
                          height: 26,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _fxColor == c
                                  ? kOrange
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOrange,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                onPressed: () {
                  if (_ctrl.text.trim().isEmpty) return;
                  widget.onSubmit(
                    StyledTextData(
                      text: _ctrl.text.trim(),
                      color: _color,
                      fontSize: _size,
                      effect: _fx,
                      effectColor: _fxColor,
                    ),
                  );
                },
                child: const Text('Add', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DraggableStyledText extends StatefulWidget {
  final StyledTextData style;
  final Offset initialPosition;
  final VoidCallback onDelete;
  const _DraggableStyledText({
    super.key,
    required this.style,
    required this.initialPosition,
    required this.onDelete,
  });
  @override
  State<_DraggableStyledText> createState() => _DraggableStyledTextState();
}

class _DraggableStyledTextState extends State<_DraggableStyledText> {
  late Offset _pos;
  bool _showControls = false;
  @override
  void initState() {
    super.initState();
    _pos = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _pos.dx,
      top: _pos.dy,
      child: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        onPanUpdate: (d) => setState(() => _pos += d.delta),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showControls)
              GestureDetector(
                onTap: widget.onDelete,
                child: Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            _buildText(widget.style),
          ],
        ),
      ),
    );
  }

  Widget _buildText(StyledTextData s) {
    final base = TextStyle(
      color: s.color,
      fontSize: s.fontSize,
      fontWeight: s.fontWeight,
    );
    switch (s.effect) {
      case TextEffect.shadow:
        return Text(
          s.text,
          style: base.copyWith(
            shadows: [
              Shadow(
                color: s.effectColor,
                blurRadius: 8,
                offset: const Offset(2, 2),
              ),
            ],
          ),
        );
      case TextEffect.outline:
        return Stack(
          children: [
            for (final off in const [
              Offset(-2, -2),
              Offset(0, -2),
              Offset(2, -2),
              Offset(-2, 0),
              Offset(2, 0),
              Offset(-2, 2),
              Offset(0, 2),
              Offset(2, 2),
            ])
              Transform.translate(
                offset: off,
                child: Text(s.text, style: base.copyWith(color: s.effectColor)),
              ),
            Text(s.text, style: base),
          ],
        );
      case TextEffect.glow:
        return ShaderMask(
          shaderCallback: (b) => LinearGradient(
            colors: [s.color, s.effectColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(b),
          child: Text(s.text, style: base.copyWith(color: Colors.white)),
        );
      case TextEffect.none:
        return Text(s.text, style: base);
    }
  }
}

class _SymmetryToolbar extends StatelessWidget {
  final SymmetryMode current;
  final ValueChanged<SymmetryMode> onChanged;
  final VoidCallback onClose;
  const _SymmetryToolbar({
    required this.current,
    required this.onChanged,
    required this.onClose,
  });
  static const _modes = [
    (SymmetryMode.none, Icons.close, 'Off'),
    (SymmetryMode.horizontal, Icons.flip, 'H'),
    (SymmetryMode.vertical, Icons.flip_camera_android, 'V'),
    (SymmetryMode.quad, Icons.grid_4x4, '4x'),
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Symmetry ',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          ..._modes.map((m) {
            final active = current == m.$1;
            return GestureDetector(
              onTap: () => onChanged(m.$1),
              child: Container(
                width: 36,
                height: 34,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: active ? kOrange : kWhite10,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      m.$2,
                      color: active ? Colors.white : Colors.grey,
                      size: 14,
                    ),
                    Text(
                      m.$3,
                      style: TextStyle(
                        color: active ? Colors.white : Colors.grey,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
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

class _SymmetryGuidePainter extends CustomPainter {
  final SymmetryMode mode;
  const _SymmetryGuidePainter(this.mode);
  // Pre-computed const color — avoids withOpacity allocation on every paint
  static const _lineColor = Color(0x80F5A623); // kOrange at ~50% opacity
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _lineColor
      ..strokeWidth = 1.5;
    final cx = size.width / 2;
    final cy = size.height / 2;
    if (mode == SymmetryMode.horizontal || mode == SymmetryMode.quad)
      canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), paint);
    if (mode == SymmetryMode.vertical || mode == SymmetryMode.quad)
      canvas.drawLine(Offset(0, cy), Offset(size.width, cy), paint);
  }

  @override
  bool shouldRepaint(_SymmetryGuidePainter o) => o.mode != mode;
}

class _NoisePainter extends CustomPainter {
  final double intensity;
  final int seed;
  const _NoisePainter({required this.intensity, required this.seed});
  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;
    final rng = math.Random(seed);
    final paint = Paint();
    final count = (size.width * size.height * intensity * 0.15).toInt();
    final alpha = (intensity * 180).toInt();
    for (var i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final bright = rng.nextDouble() > 0.5;
      paint.color = bright
          ? Color.fromARGB(alpha, 255, 255, 255)
          : Color.fromARGB(alpha, 0, 0, 0);
      canvas.drawCircle(Offset(x, y), 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(_NoisePainter o) =>
      o.intensity != intensity || o.seed != seed;
}

class _NoiseOverlayPanel extends StatelessWidget {
  final double intensity;
  final ValueChanged<double> onChanged;
  final VoidCallback onClose;
  const _NoiseOverlayPanel({
    required this.intensity,
    required this.onChanged,
    required this.onClose,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      child: Row(
        children: [
          const Icon(Icons.grain, color: kOrange, size: 18),
          const SizedBox(width: 6),
          const Text(
            'Grain',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
          Expanded(
            child: Slider(
              value: intensity,
              min: 0,
              max: 1,
              activeColor: kOrange,
              inactiveColor: kWhite10,
              onChanged: onChanged,
            ),
          ),
          Text(
            '${(intensity * 100).round()}%',
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

class _BlendModePanel extends StatelessWidget {
  final BlendMode selected;
  final ValueChanged<BlendMode> onSelect;
  final VoidCallback onClose;
  const _BlendModePanel({
    required this.selected,
    required this.onSelect,
    required this.onClose,
  });
  static const _modes = [
    (BlendMode.srcOver, 'Normal'),
    (BlendMode.multiply, 'Multiply'),
    (BlendMode.screen, 'Screen'),
    (BlendMode.overlay, 'Overlay'),
    (BlendMode.darken, 'Darken'),
    (BlendMode.lighten, 'Lighten'),
    (BlendMode.colorDodge, 'Dodge'),
    (BlendMode.colorBurn, 'Burn'),
    (BlendMode.hardLight, 'Hard Light'),
    (BlendMode.softLight, 'Soft Light'),
    (BlendMode.difference, 'Difference'),
    (BlendMode.exclusion, 'Exclusion'),
    (BlendMode.hue, 'Hue'),
    (BlendMode.saturation, 'Saturation'),
    (BlendMode.color, 'Color'),
    (BlendMode.luminosity, 'Luminosity'),
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Blend Mode',
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
          SizedBox(
            height: 220,
            child: ListView(
              children: _modes.map((m) {
                final active = selected == m.$1;
                return GestureDetector(
                  onTap: () => onSelect(m.$1),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: active ? kOrange : kWhite10,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Text(
                      m.$2,
                      style: TextStyle(
                        color: active ? Colors.white : Colors.grey,
                        fontSize: 13,
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
