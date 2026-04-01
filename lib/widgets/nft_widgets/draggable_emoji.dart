import 'package:flutter/material.dart';
import 'package:nft_create/models/emoji_item.dart';

const kOrange = Color(0xFFF5A623);

class DraggableEmoji extends StatefulWidget {
  final EmojiItem item;
  final ValueChanged<Offset> onMove;
  final VoidCallback onDelete;

  const DraggableEmoji({
    super.key,
    required this.item,
    required this.onMove,
    required this.onDelete,
  });

  @override
  State<DraggableEmoji> createState() => _DraggableEmojiState();
}

class _DraggableEmojiState extends State<DraggableEmoji> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.item.position.dx - 24,
      top: widget.item.position.dy - 24,
      child: GestureDetector(
        onTap: () => setState(() => _selected = !_selected),
        onPanUpdate: (d) => widget.onMove(
          Offset(
            widget.item.position.dx + d.delta.dx,
            widget.item.position.dy + d.delta.dy,
          ),
        ),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: _selected
                  ? BoxDecoration(
                      border: Border.all(color: kOrange, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: Text(
                widget.item.emoji,
                style: const TextStyle(fontSize: 36),
              ),
            ),
            if (_selected)
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
