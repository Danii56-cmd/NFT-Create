// import 'package:flutter/material.dart';
// import 'package:nft_create/constants/nft_screen_constants.dart';
// import 'package:nft_create/models/drawing_point.dart';
// import 'package:nft_create/models/emoji_item.dart';
// import 'package:nft_create/models/shape_item.dart';
// import 'package:nft_create/models/text_item.dart';
// import 'package:nft_create/painters/drawing_painters.dart';
// import 'package:nft_create/widgets/nft_widgets/dragable_text.dart';
// import 'package:nft_create/widgets/nft_widgets/draggable_emoji.dart';

// class DrawingCanvas extends StatelessWidget {
//   // ── Core Drawing Data ──────────────────────
//   final GlobalKey canvasKey;
//   final Color bgColor;
//   final List<List<DrawingPoint?>> strokes;
//   final List<DrawingPoint?> currentStroke;
//   final List<ShapeItem> shapes;
//   final List<EmojiItem> emojis;
//   final List<TextItem> textItems;

//   // ── Tool State ─────────────────────────────
//   final String? addingEmoji;
//   final DrawingTool tool;
//   final Color strokeColor;
//   final double strokeWidth;
//   final ShapeType shapeType;
//   final Offset? shapeStart;
//   final Offset textPosition;
//   final bool showTextInput;

//   // ── Panel Visibility ───────────────────────
//   final bool showColorPicker;
//   final bool showStrokeSlider;
//   final bool showShapePicker;
//   final bool showEmojiPicker;
//   final bool showLayerPanel;

//   // ── Gesture Callbacks ──────────────────────
//   final Function(Offset) onTapDown;
//   final Function(Offset) onPanStart;
//   final Function(Offset) onPanUpdate;
//   final VoidCallback onPanEnd;

//   // ── Emoji Callbacks ────────────────────────
//   final Function(int index, Offset pos) onEmojiMove;
//   final Function(int index) onEmojiDelete;

//   // ── Text Callbacks ─────────────────────────
//   final Function(int index, Offset pos) onTextMove;
//   final Function(int index) onTextDelete;
//   final Function(String text, Color color, double size) onTextSubmit;
//   final VoidCallback onTextCancel;

//   // ── Color Panel Callbacks ──────────────────
//   final Function(Color) onColorSelected;
//   final Function(Color) onBgColorSelected;
//   final VoidCallback onColorPickerClose;

//   // ── Stroke Slider Callbacks ────────────────
//   final Function(double) onStrokeWidthChanged;
//   final VoidCallback onStrokeSliderClose;

//   // ── Shape Picker Callbacks ─────────────────
//   final Function(ShapeType) onShapeSelected;
//   final VoidCallback onShapePickerClose;

//   // ── Emoji Picker Callbacks ─────────────────
//   final Function(String) onEmojiSelected;
//   final VoidCallback onEmojiPickerClose;

//   // ── Layer Panel Callbacks ──────────────────
//   final Function(int) onLayerSelected;
//   final VoidCallback onAddLayer;
//   final VoidCallback onLayerPanelClose;

//   const DrawingCanvas({
//     super.key,
//     // Core
//     required this.canvasKey,
//     required this.bgColor,
//     required this.strokes,
//     required this.currentStroke,
//     required this.shapes,
//     required this.emojis,
//     required this.textItems,
//     // Tool state
//     required this.addingEmoji,
//     required this.tool,
//     required this.strokeColor,
//     required this.strokeWidth,
//     required this.shapeType,
//     required this.shapeStart,
//     required this.textPosition,
//     required this.showTextInput,
//     // Panel visibility
//     required this.showColorPicker,
//     required this.showStrokeSlider,
//     required this.showShapePicker,
//     required this.showEmojiPicker,
//     required this.showLayerPanel,
//     // Gestures
//     required this.onTapDown,
//     required this.onPanStart,
//     required this.onPanUpdate,
//     required this.onPanEnd,
//     // Emoji
//     required this.onEmojiMove,
//     required this.onEmojiDelete,
//     // Text
//     required this.onTextMove,
//     required this.onTextDelete,
//     required this.onTextSubmit,
//     required this.onTextCancel,
//     // Color
//     required this.onColorSelected,
//     required this.onBgColorSelected,
//     required this.onColorPickerClose,
//     // Stroke
//     required this.onStrokeWidthChanged,
//     required this.onStrokeSliderClose,
//     // Shape
//     required this.onShapeSelected,
//     required this.onShapePickerClose,
//     // Emoji picker
//     required this.onEmojiSelected,
//     required this.onEmojiPickerClose,
//     // Layer
//     required this.onLayerSelected,
//     required this.onAddLayer,
//     required this.onLayerPanelClose,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (d) => onTapDown(d.localPosition),
//       onPanStart: (d) => onPanStart(d.localPosition),
//       onPanUpdate: (d) => onPanUpdate(d.localPosition),
//       onPanEnd: (_) => onPanEnd(),
//       child: RepaintBoundary(
//         key: canvasKey,
//         child: Container(
//           margin: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: bgColor,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: Stack(
//               children: [
//                 // ── Drawing Canvas ──
//                 CustomPaint(
//                   painter: DrawingPainter(
//                     strokes: strokes,
//                     currentStroke: currentStroke,
//                     shapes: shapes,
//                   ),
//                   size: Size.infinite,
//                 ),

//                 // ── Placed Emojis ──
//                 ...emojis.asMap().entries.map(
//                   (entry) => DraggableEmoji(
//                     item: entry.value,
//                     onMove: (pos) => onEmojiMove(entry.key, pos),
//                     onDelete: () => onEmojiDelete(entry.key),
//                   ),
//                 ),

//                 // ── Text Items ──
//                 ...textItems.asMap().entries.map(
//                   (entry) => DraggableText(
//                     item: entry.value,
//                     onMove: (pos) => onTextMove(entry.key, pos),
//                     onDelete: () => onTextDelete(entry.key),
//                   ),
//                 ),

//                 // ── Empty State ──
//                 if (strokes.isEmpty &&
//                     emojis.isEmpty &&
//                     textItems.isEmpty &&
//                     shapes.isEmpty)
//                   const Center(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.palette_outlined,
//                           color: Color(0xFFF5A623),
//                           size: 48,
//                         ),
//                         SizedBox(height: 12),
//                         Text(
//                           'Tap to start creating',
//                           style: TextStyle(
//                             color: Color(0xFFAAAAAA),
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                 // ── Emoji placement hint ──
//                 if (addingEmoji != null)
//                   Positioned(
//                     bottom: 20,
//                     left: 0,
//                     right: 0,
//                     child: Center(
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF5A623),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           'Tap canvas to place  $addingEmoji',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
