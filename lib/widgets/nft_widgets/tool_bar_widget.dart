// import 'package:flutter/material.dart';
// import 'package:nft_create/constants/nft_screen_constants.dart';

// class AppToolbar extends StatelessWidget {
//   final DrawingTool currentTool;
//   final Color strokeColor;
//   final VoidCallback onMenuTap;
//   final VoidCallback onUndo;
//   final VoidCallback onRedo;
//   final VoidCallback onShapesTap;
//   final VoidCallback onEraserTap;
//   final VoidCallback onColorTap;
//   final VoidCallback onWidthTap;
//   final VoidCallback onEmojiTap;
//   final VoidCallback onTextTap;
//   final VoidCallback onLayersTap;
//   final VoidCallback onClearTap;

//   const AppToolbar({
//     super.key,
//     required this.currentTool,
//     required this.strokeColor,
//     required this.onMenuTap,
//     required this.onUndo,
//     required this.onRedo,
//     required this.onShapesTap,
//     required this.onEraserTap,
//     required this.onColorTap,
//     required this.onWidthTap,
//     required this.onEmojiTap,
//     required this.onTextTap,
//     required this.onLayersTap,
//     required this.onClearTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 60,
//       margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
//       decoration: BoxDecoration(
//         color: kOrange,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: kOrange.withOpacity(0.4),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _toolBtn(Icons.menu, 'Menu', onTap: onMenuTap),
//           _toolBtn(Icons.undo, 'Undo', onTap: onUndo),
//           _toolBtn(Icons.redo, 'Redo', onTap: onRedo),
//           _toolBtn(
//             Icons.category_outlined,
//             'Shapes',
//             active: currentTool == DrawingTool.shapes,
//             onTap: onShapesTap,
//           ),
//           _toolBtn(
//             Icons.close,
//             'Erase',
//             active: currentTool == DrawingTool.eraser,
//             onTap: onEraserTap,
//           ),
//           _colorBtn(strokeColor, onColorTap),
//           _toolBtn(Icons.line_weight, 'Width', onTap: onWidthTap),
//           _toolBtn(Icons.emoji_emotions_outlined, 'Emoji', onTap: onEmojiTap),
//           _toolBtn(
//             Icons.text_fields,
//             'Text',
//             active: currentTool == DrawingTool.text,
//             onTap: onTextTap,
//           ),
//           _toolBtn(Icons.layers_outlined, 'Layers', onTap: onLayersTap),
//           _toolBtn(Icons.delete_outline, 'Clear', onTap: onClearTap),
//         ],
//       ),
//     );
//   }

//   Widget _toolBtn(
//     IconData icon,
//     String tooltip, {
//     VoidCallback? onTap,
//     bool active = false,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 34,
//         height: 34,
//         decoration: BoxDecoration(
//           color: active ? Colors.white.withOpacity(0.3) : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Icon(icon, color: Colors.white, size: 20),
//       ),
//     );
//   }

//   Widget _colorBtn(Color color, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 34,
//         height: 34,
//         decoration: BoxDecoration(
//           color: color,
//           shape: BoxShape.circle,
//           border: Border.all(color: Colors.white, width: 2),
//         ),
//       ),
//     );
//   }
// }
