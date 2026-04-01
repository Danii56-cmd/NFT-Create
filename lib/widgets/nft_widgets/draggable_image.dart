// lib/widgets/nft_widgets/draggable_image.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nft_create/models/image_item.dart';

const kOrange = Color(0xFFF5A623);

class DraggableImage extends StatefulWidget {
  final ImageItem item;
  final bool locked;
  final void Function(Offset) onMove;
  final void Function(double) onScale;
  final VoidCallback onDelete;
  final VoidCallback onBringToFront;
  final VoidCallback onDuplicate;
  final VoidCallback onToggleLock;
  final void Function(ImageFilter) onFilterChanged;

  const DraggableImage({
    super.key,
    required this.item,
    required this.locked,
    required this.onMove,
    required this.onScale,
    required this.onDelete,
    required this.onBringToFront,
    required this.onDuplicate,
    required this.onToggleLock,
    required this.onFilterChanged,
  });

  @override
  State<DraggableImage> createState() => _DraggableImageState();
}

class _DraggableImageState extends State<DraggableImage> {
  Offset _lastFocalPoint = Offset.zero;
  double _baseScale = 1.0;
  bool _selected = false;
  bool _showFilterBar = false;

  static const double _baseSize = 120.0;
  static const double _pad = 14.0;

  // ── Filter → ColorFilter ──
  ColorFilter? _colorFilter(ImageFilter f) {
    switch (f) {
      case ImageFilter.none:
        return null;
      case ImageFilter.grayscale:
        return const ColorFilter.matrix([
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case ImageFilter.sepia:
        return const ColorFilter.matrix([
          0.393,
          0.769,
          0.189,
          0,
          0,
          0.349,
          0.686,
          0.168,
          0,
          0,
          0.272,
          0.534,
          0.131,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case ImageFilter.invert:
        return const ColorFilter.matrix([
          -1,
          0,
          0,
          0,
          255,
          0,
          -1,
          0,
          0,
          255,
          0,
          0,
          -1,
          0,
          255,
          0,
          0,
          0,
          1,
          0,
        ]);
      case ImageFilter.vintage:
        return const ColorFilter.matrix([
          0.9,
          0.5,
          0.1,
          0,
          0,
          0.3,
          0.8,
          0.1,
          0,
          0,
          0.2,
          0.3,
          0.5,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = _baseSize * widget.item.scale;
    final cf = _colorFilter(widget.item.filter);

    return Positioned(
      left: widget.item.position.dx - _pad,
      top: widget.item.position.dy - _pad,
      child: SizedBox(
        width: size + _pad * 2,
        height: size + _pad * 2 + (_showFilterBar ? 44 : 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Image + controls ──
            SizedBox(
              width: size + _pad * 2,
              height: size + _pad * 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => setState(() => _selected = !_selected),
                onScaleStart: widget.locked
                    ? null
                    : (d) {
                        _lastFocalPoint = d.focalPoint;
                        _baseScale = widget.item.scale;
                      },
                onScaleUpdate: widget.locked
                    ? null
                    : (d) {
                        final delta = d.focalPoint - _lastFocalPoint;
                        _lastFocalPoint = d.focalPoint;
                        widget.onMove(widget.item.position + delta);
                        if (d.scale != 1.0) {
                          widget.onScale(
                            (_baseScale * d.scale).clamp(0.3, 5.0),
                          );
                        }
                      },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Image
                    Positioned(
                      left: _pad,
                      top: _pad,
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: _selected
                              ? Border.all(color: kOrange, width: 2)
                              : widget.locked
                              ? Border.all(color: Colors.blue, width: 2)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: cf != null
                              ? ColorFiltered(
                                  colorFilter: cf,
                                  child: Image.file(
                                    File(widget.item.file.path),
                                    width: size,
                                    height: size,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.file(
                                  File(widget.item.file.path),
                                  width: size,
                                  height: size,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),

                    // Lock badge
                    if (widget.locked)
                      Positioned(
                        left: _pad + 4,
                        bottom: _pad + 4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.85),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),

                    if (_selected) ...[
                      // Delete — top left
                      Positioned(
                        top: 0,
                        left: 0,
                        child: _CtrlBtn(
                          icon: Icons.close,
                          color: Colors.red,
                          onTap: widget.onDelete,
                        ),
                      ),
                      // Bring to front — top right
                      Positioned(
                        top: 0,
                        right: 0,
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
                        bottom: 0,
                        left: 0,
                        child: _CtrlBtn(
                          icon: Icons.copy,
                          color: Colors.green,
                          onTap: () {
                            widget.onDuplicate();
                            setState(() => _selected = false);
                          },
                        ),
                      ),
                      // Lock toggle — bottom center-ish
                      Positioned(
                        bottom: 0,
                        left: size / 2,
                        child: _CtrlBtn(
                          icon: widget.locked ? Icons.lock_open : Icons.lock,
                          color: Colors.blue,
                          onTap: () {
                            widget.onToggleLock();
                            setState(() => _selected = false);
                          },
                        ),
                      ),
                      // Filter — bottom right (toggle filter bar)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: _CtrlBtn(
                          icon: Icons.auto_fix_high,
                          color: Colors.purple,
                          onTap: () =>
                              setState(() => _showFilterBar = !_showFilterBar),
                        ),
                      ),
                      // Resize handle
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onPanUpdate: (d) {
                            final delta = d.delta.dx + d.delta.dy;
                            widget.onScale(
                              (widget.item.scale + delta / 80).clamp(0.3, 5.0),
                            );
                          },
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: kOrange, width: 2),
                            ),
                            child: const Icon(
                              Icons.open_in_full,
                              size: 12,
                              color: kOrange,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Filter bar ──
            if (_selected && _showFilterBar)
              Container(
                height: 40,
                margin: EdgeInsets.only(left: _pad, right: _pad),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  children: ImageFilter.values.map((f) {
                    final active = widget.item.filter == f;
                    return GestureDetector(
                      onTap: () => widget.onFilterChanged(f),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: active
                              ? kOrange
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            f.name[0].toUpperCase() + f.name.substring(1),
                            style: TextStyle(
                              color: active ? Colors.white : Colors.grey,
                              fontSize: 11,
                              fontWeight: active
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
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
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
    );
  }
}
