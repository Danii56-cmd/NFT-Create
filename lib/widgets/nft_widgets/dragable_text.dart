// lib/widgets/nft_widgets/dragable_text.dart

import 'package:flutter/material.dart';
import 'package:nft_create/models/text_item.dart';

const kOrange = Color(0xFFF5A623);

class DraggableText extends StatefulWidget {
  final TextItem item;
  final bool locked;
  final ValueChanged<Offset> onMove;
  final VoidCallback onDelete;
  final VoidCallback onBringToFront;
  final VoidCallback onDuplicate;
  final VoidCallback onToggleLock;

  const DraggableText({
    super.key,
    required this.item,
    required this.locked,
    required this.onMove,
    required this.onDelete,
    required this.onBringToFront,
    required this.onDuplicate,
    required this.onToggleLock,
  });

  @override
  State<DraggableText> createState() => _DraggableTextState();
}

class _DraggableTextState extends State<DraggableText> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.item.position.dx - 10,
      top: widget.item.position.dy - 10,
      child: GestureDetector(
        onTap: () => setState(() => _selected = !_selected),
        onPanUpdate: widget.locked
            ? null
            : (d) => widget.onMove(
                Offset(
                  widget.item.position.dx + d.delta.dx,
                  widget.item.position.dy + d.delta.dy,
                ),
              ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selected
                      ? kOrange
                      : widget.locked
                      ? Colors.blue
                      : Colors.transparent,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.item.text,
                style: TextStyle(
                  color: widget.item.color,
                  fontSize: widget.item.size,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            if (_selected) ...[
              // Delete
              Positioned(
                left: -8,
                top: -8,
                child: _CtrlBtn(
                  icon: Icons.close,
                  color: Colors.red,
                  onTap: widget.onDelete,
                ),
              ),
              // Bring to front
              Positioned(
                right: -8,
                top: -8,
                child: _CtrlBtn(
                  icon: Icons.flip_to_front,
                  color: kOrange,
                  onTap: () {
                    widget.onBringToFront();
                    setState(() => _selected = false);
                  },
                ),
              ),
              // Duplicate
              Positioned(
                left: -8,
                bottom: -8,
                child: _CtrlBtn(
                  icon: Icons.copy,
                  color: Colors.green,
                  onTap: () {
                    widget.onDuplicate();
                    setState(() => _selected = false);
                  },
                ),
              ),
              // Lock
              Positioned(
                right: -8,
                bottom: -8,
                child: _CtrlBtn(
                  icon: widget.locked ? Icons.lock_open : Icons.lock,
                  color: Colors.blue,
                  onTap: () {
                    widget.onToggleLock();
                    setState(() => _selected = false);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _CtrlBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 12),
      ),
    );
  }
}
