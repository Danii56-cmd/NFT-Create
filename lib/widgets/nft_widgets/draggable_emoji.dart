import 'package:flutter/material.dart';
import 'package:nft_create/models/emoji_item.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _kOrange = Color(0xFFF5A623);
const _kPanel = Color(0xFF1E1E1E);
const _kWhite10 = Color(0x1AFFFFFF);
const _kOrange10 = Color(0x1AF5A623);

class DraggableEmoji extends StatefulWidget {
  final EmojiItem item;
  final bool locked;
  final void Function(Offset) onMove;
  final VoidCallback onDelete;
  final VoidCallback onBringToFront;
  final VoidCallback onDuplicate;
  final VoidCallback onToggleLock;

  const DraggableEmoji({
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
  State<DraggableEmoji> createState() => _DraggableEmojiState();
}

class _DraggableEmojiState extends State<DraggableEmoji> {
  // ── All fields are eagerly initialised — zero `late`, zero dynamic casts ───
  Offset _position = Offset.zero; // set in initState from widget.item
  double _fontSize = 40.0; // local-only; no model change required
  double _rotation = 0.0;

  bool _selected = false;
  bool _showSizeSlider = false;

  // Captured at the START of each gesture so updates are relative, not additive
  double _scaleAtStart = 40.0;
  double _rotationAtStart = 0.0;

  static const double _minSize = 16.0;
  static const double _maxSize = 200.0;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _position = widget.item.position; // safe — always non-null in your model
  }

  @override
  void didUpdateWidget(DraggableEmoji old) {
    super.didUpdateWidget(old);
    // If the provider swaps the underlying item (undo/redo), sync position
    if (old.item.id != widget.item.id) {
      _position = widget.item.position;
      _fontSize = 40.0;
      _rotation = 0.0;
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────
  void _dismiss() => setState(() {
    _selected = false;
    _showSizeSlider = false;
  });

  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        // ── Tap: toggle selection ──────────────────────────────────────────
        onTap: () {
          if (widget.locked) return;
          setState(() {
            _selected = !_selected;
            if (!_selected) _showSizeSlider = false;
          });
          if (_selected) widget.onBringToFront();
        },

        // ── Double-tap: open / close the size slider ───────────────────────
        onDoubleTap: () {
          if (widget.locked) return;
          setState(() {
            _selected = true;
            _showSizeSlider = !_showSizeSlider;
          });
        },

        // ── Scale gesture: 1 finger = move, 2 fingers = resize + rotate ────
        onScaleStart: (d) {
          if (widget.locked) return;
          _scaleAtStart = _fontSize;
          _rotationAtStart = _rotation;
        },
        onScaleUpdate: (d) {
          if (widget.locked) return;
          setState(() {
            if (d.pointerCount >= 2) {
              _fontSize = (_scaleAtStart * d.scale).clamp(_minSize, _maxSize);
              _rotation = _rotationAtStart + d.rotation;
            } else {
              _position += d.focalPointDelta;
              widget.onMove(_position);
            }
          });
        },

        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Control bar (only when selected and unlocked)
            if (_selected && !widget.locked) _buildControlBar(),

            // The emoji itself
            Transform.rotate(
              angle: _rotation,
              child: Text(
                widget.item.emoji,
                style: TextStyle(fontSize: _fontSize),
              ),
            ),

            // Size slider (only on double-tap)
            if (_showSizeSlider && !widget.locked) _buildSizeSlider(),
          ],
        ),
      ),
    );
  }

  // ── Control bar ───────────────────────────────────────────────────────────
  Widget _buildControlBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: _kPanel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kOrange, width: 1),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Live size badge
          _badge('${_fontSize.round()}px', _kOrange10, _kOrange),
          const SizedBox(width: 4),

          _iconBtn(
            Icons.straighten,
            _showSizeSlider ? _kOrange : Colors.grey,
            () => setState(() => _showSizeSlider = !_showSizeSlider),
            tooltip: 'Resize',
          ),
          _iconBtn(
            Icons.flip_to_front,
            Colors.grey,
            widget.onBringToFront,
            tooltip: 'Bring forward',
          ),
          _iconBtn(
            Icons.copy,
            Colors.grey,
            widget.onDuplicate,
            tooltip: 'Duplicate',
          ),
          _iconBtn(
            widget.locked ? Icons.lock : Icons.lock_open,
            widget.locked ? _kOrange : Colors.grey,
            widget.onToggleLock,
            tooltip: widget.locked ? 'Unlock' : 'Lock',
          ),
          _iconBtn(Icons.close, Colors.grey, _dismiss, tooltip: 'Deselect'),
          _iconBtn(
            Icons.delete_outline,
            Colors.redAccent,
            widget.onDelete,
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  // ── Size slider panel ──────────────────────────────────────────────────────
  Widget _buildSizeSlider() {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _kPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kOrange, width: 1),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 8)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Slider row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.text_decrease, color: Colors.grey, size: 14),
              SizedBox(
                width: 160,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                    activeTrackColor: _kOrange,
                    inactiveTrackColor: _kWhite10,
                    thumbColor: _kOrange,
                    overlayColor: const Color(0x33F5A623),
                  ),
                  child: Slider(
                    value: _fontSize,
                    min: _minSize,
                    max: _maxSize,
                    onChanged: (v) => setState(() => _fontSize = v),
                  ),
                ),
              ),
              const Icon(Icons.text_increase, color: _kOrange, size: 14),
              const SizedBox(width: 6),
              Text(
                '${_fontSize.round()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Quick-size preset buttons
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [24.0, 40.0, 60.0, 80.0, 120.0].map((size) {
              final active = (_fontSize - size).abs() < 1;
              return GestureDetector(
                onTap: () => setState(() => _fontSize = size),
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: active ? _kOrange : _kWhite10,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${size.round()}',
                    style: TextStyle(
                      color: active ? Colors.white : Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Static micro-helpers ───────────────────────────────────────────────────
  static Widget _iconBtn(
    IconData icon,
    Color color,
    VoidCallback onTap, {
    String tooltip = '',
  }) => Tooltip(
    message: tooltip,
    child: GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(icon, color: color, size: 16),
      ),
    ),
  );

  static Widget _badge(String label, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
    ),
  );
}
