// lib/widgets/nft_widgets/draggable_shapes.dart

import 'package:flutter/material.dart';
import 'package:nft_create/enums.dart';
import 'package:nft_create/models/shape_item.dart';

const kOrange = Color(0xFFF5A623);

class DraggableShape extends StatefulWidget {
  final ShapeItem item;
  final bool locked;
  final ValueChanged<Offset> onMove;
  final VoidCallback onDelete;
  final VoidCallback onBringToFront;
  final VoidCallback onDuplicate;
  final VoidCallback onToggleLock;

  const DraggableShape({
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
  State<DraggableShape> createState() => _DraggableShapeState();
}

class _DraggableShapeState extends State<DraggableShape> {
  bool _selected = false;

  Rect get _bounds {
    final s = widget.item.start + widget.item.offset;
    final e = widget.item.end + widget.item.offset;
    return Rect.fromPoints(s, e);
  }

  @override
  Widget build(BuildContext context) {
    final bounds = _bounds;
    const padding = 16.0;

    return Positioned(
      left: bounds.left - padding,
      top: bounds.top - padding,
      child: GestureDetector(
        onTap: () => setState(() => _selected = !_selected),
        onPanUpdate: widget.locked
            ? null
            : (d) => widget.onMove(
                Offset(
                  widget.item.offset.dx + d.delta.dx,
                  widget.item.offset.dy + d.delta.dy,
                ),
              ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: bounds.width + padding * 2,
              height: bounds.height + padding * 2,
              decoration: (_selected || widget.locked)
                  ? BoxDecoration(
                      border: Border.all(
                        color: _selected ? kOrange : Colors.blue,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    )
                  : null,
              child: CustomPaint(
                painter: _SingleShapePainter(
                  item: widget.item,
                  padding: padding,
                ),
              ),
            ),

            if (widget.locked)
              Positioned(
                left: padding + 4,
                bottom: padding + 4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.85),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock, color: Colors.white, size: 12),
                ),
              ),

            if (_selected) ...[
              // Delete — top left
              Positioned(
                left: 0,
                top: 0,
                child: _CtrlBtn(
                  icon: Icons.close,
                  color: Colors.red,
                  onTap: widget.onDelete,
                ),
              ),
              // Bring to front — top right
              Positioned(
                right: 0,
                top: 0,
                child: _CtrlBtn(
                  icon: Icons.flip_to_front,
                  color: kOrange,
                  onTap: () {
                    widget.onBringToFront();
                    setState(() => _selected = false);
                  },
                ),
              ),
              // Duplicate — bottom left
              Positioned(
                left: 0,
                bottom: 0,
                child: _CtrlBtn(
                  icon: Icons.copy,
                  color: Colors.green,
                  onTap: () {
                    widget.onDuplicate();
                    setState(() => _selected = false);
                  },
                ),
              ),
              // Lock — bottom right
              Positioned(
                right: 0,
                bottom: 0,
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

class _SingleShapePainter extends CustomPainter {
  final ShapeItem item;
  final double padding;
  _SingleShapePainter({required this.item, required this.padding});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = item.color
      ..strokeWidth = item.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final s = item.start + item.offset;
    final e = item.end + item.offset;
    final bounds = Rect.fromPoints(s, e);
    canvas.save();
    canvas.translate(-bounds.left + padding, -bounds.top + padding);
    final rect = Rect.fromPoints(s, e);

    switch (item.type) {
      case ShapeType.rectangle:
        canvas.drawRect(rect, paint);
        break;
      case ShapeType.circle:
        canvas.drawOval(rect, paint);
        break;
      case ShapeType.line:
        canvas.drawLine(s, e, paint);
        break;
      case ShapeType.triangle:
        final path = Path()
          ..moveTo((s.dx + e.dx) / 2, s.dy)
          ..lineTo(e.dx, e.dy)
          ..lineTo(s.dx, e.dy)
          ..close();
        canvas.drawPath(path, paint);
        break;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SingleShapePainter old) => true;
}
