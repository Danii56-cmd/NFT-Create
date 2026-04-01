import 'package:flutter/material.dart';
import 'package:nft_create/models/text_item.dart';

const kOrange = Color(0xFFF5A623);

class DraggableText extends StatefulWidget {
  final TextItem item;
  final ValueChanged<Offset> onMove;
  final VoidCallback onDelete;

  const DraggableText({
    super.key,
    required this.item,
    required this.onMove,
    required this.onDelete,
  });

  @override
  State<DraggableText> createState() => _DraggableTextState();
}

class _DraggableTextState extends State<DraggableText> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.item.position.dx,
      top: widget.item.position.dy,
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
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: _selected
                  ? BoxDecoration(
                      border: Border.all(color: kOrange, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                    )
                  : null,
              child: Text(
                widget.item.text,
                style: TextStyle(
                  color: widget.item.color,
                  fontSize: widget.item.size,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_selected)
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 10,
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
