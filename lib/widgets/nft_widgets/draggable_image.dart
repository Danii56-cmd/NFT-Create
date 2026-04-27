<<<<<<< HEAD
=======
// lib/widgets/nft_widgets/draggable_image.dart

>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
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

<<<<<<< HEAD
=======
  // ── Filter → ColorFilter ──────────────────────────────────────────────────
  // FIX: Return null for 'none' so we never wrap with a no-op ColorFilter.
  // The old code used ColorFilter.mode(Colors.transparent, BlendMode.src)
  // which renders the image as a black rectangle.
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
  ColorFilter? _colorFilter(ImageFilter f) {
    switch (f) {
      case ImageFilter.none:
        return null; // no wrapper at all — avoids black-image bug
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

<<<<<<< HEAD
=======
  // ── Build the image widget (file OR bytes) ────────────────────────────────
  // FIX: Wrap with ColorFiltered only when a filter is actually needed.
  // Previously the bytes branch always wrapped — even for ImageFilter.none —
  // with `ColorFilter.mode(Colors.transparent, BlendMode.src)` which
  // composites the image with transparent black → black rectangle.
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
  Widget _buildImage(double size, ColorFilter? cf) {
    final bytes = widget.item.bytes;
    final file = widget.item.file;

    Widget raw;

    if (bytes != null && bytes.isNotEmpty) {
<<<<<<< HEAD
=======
      // AI-generated image stored in memory
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
      raw = Image.memory(
        bytes,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true, // prevents flicker on scale change
        errorBuilder: (_, error, __) {
          debugPrint('Image.memory error: $error');
          return _errorPlaceholder(size);
        },
      );
    } else if (file != null) {
      // Regular file-picked image
      raw = Image.file(
        file,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, error, __) {
          debugPrint('Image.file error: $error');
          return _errorPlaceholder(size);
        },
      );
    } else {
      return _errorPlaceholder(size);
    }

<<<<<<< HEAD
=======
    // Only wrap with ColorFiltered when a real filter is selected
>>>>>>> 2bc536004d56b3337f5650ef5e62124308594628
    if (cf != null) {
      return ColorFiltered(colorFilter: cf, child: raw);
    }
    return raw;
  }

  Widget _errorPlaceholder(double size) => Container(
    width: size,
    height: size,
    color: Colors.grey[800],
    child: const Center(
      child: Icon(Icons.broken_image, color: Colors.white54, size: 40),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final size = _baseSize * widget.item.scale;
    final cf = _colorFilter(widget.item.filter);

    return Positioned(
      left: widget.item.position.dx - _pad,
      top: widget.item.position.dy - _pad,
      child: SizedBox(
        width: size + _pad * 2,
        height: size + _pad * 2 + (_showFilterBar && _selected ? 44 : 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Image + gesture controls ──────────────────────────────────
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
                    // ── Image ─────────────────────────────────────────────
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
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildImage(size, cf),
                        ),
                      ),
                    ),

                    // ── Lock badge ─────────────────────────────────────────
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

                    // ── Selection controls ─────────────────────────────────
                    if (_selected) ...[
                      // Delete (top-left)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: _CtrlBtn(
                          icon: Icons.close,
                          color: Colors.red,
                          onTap: widget.onDelete,
                        ),
                      ),
                      // Bring to front (top-right)
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
                      // Duplicate (bottom-left)
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
                      // Lock toggle (bottom-center)
                      Positioned(
                        bottom: 0,
                        left: _pad + size / 2 - 12,
                        child: _CtrlBtn(
                          icon: widget.locked ? Icons.lock_open : Icons.lock,
                          color: Colors.blue,
                          onTap: () {
                            widget.onToggleLock();
                            setState(() => _selected = false);
                          },
                        ),
                      ),
                      // Filter toggle (bottom-right area)
                      Positioned(
                        bottom: 0,
                        right: 28, // offset so it doesn't overlap resize handle
                        child: _CtrlBtn(
                          icon: Icons.auto_fix_high,
                          color: Colors.purple,
                          onTap: () =>
                              setState(() => _showFilterBar = !_showFilterBar),
                        ),
                      ),
                      // Resize handle (bottom-right corner)
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

            // ── Filter bar ────────────────────────────────────────────────
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
          boxShadow: const [BoxShadow(color: Color(0x4D000000), blurRadius: 4)],
        ),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
    );
  }
}
