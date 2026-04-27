// ignore_for_file: unreachable_switch_default

import 'package:flutter/material.dart';
import 'package:nft_create/models/canvas_item.dart';
import 'package:nft_create/models/image_item.dart';
import 'package:nft_create/models/layer_data.dart';
import 'package:nft_create/models/text_item.dart';
import 'package:nft_create/models/shape_item.dart';
import 'package:nft_create/models/emoji_item.dart';

const _kOrange = Color(0xFFF5A623);
const _kPanel = Color(0xFF1E1E1E);
const _kWhite10 = Color(0x1AFFFFFF);

class LayerPanel extends StatelessWidget {
  final List<LayerData> layers;
  final int activeIndex;
  final List<CanvasItem> canvasItems; // ← full ordered list

  final VoidCallback onAdd;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onToggleVisibility;
  final ValueChanged<int> onDelete;
  final void Function(int, String) onRename;
  final VoidCallback onClose;

  // item z-order callbacks
  final ValueChanged<CanvasItem> onBringToFront;
  final ValueChanged<CanvasItem> onSendToBack;
  final ValueChanged<CanvasItem> onBringForward;
  final ValueChanged<CanvasItem> onSendBackward;
  final ValueChanged<CanvasItem> onDeleteItem;
  final void Function(List<CanvasItem>) onReorder; // drag reorder

  const LayerPanel({
    super.key,
    required this.layers,
    required this.activeIndex,
    required this.canvasItems,
    required this.onAdd,
    required this.onSelect,
    required this.onToggleVisibility,
    required this.onDelete,
    required this.onRename,
    required this.onClose,
    required this.onBringToFront,
    required this.onSendToBack,
    required this.onBringForward,
    required this.onSendBackward,
    required this.onDeleteItem,
    required this.onReorder,
  });

  // ── helpers ──────────────────────────────────────────────────────────────
  static IconData _iconFor(CanvasItem ci) {
    switch (ci.type) {
      case CanvasItemType.image:
        return Icons.image_outlined;
      case CanvasItemType.text:
        return Icons.text_fields;
      case CanvasItemType.shape:
        return Icons.category_outlined;
      case CanvasItemType.emoji:
        return Icons.emoji_emotions_outlined;
      default:
        return Icons.layers;
    }
  }

  static String _labelFor(CanvasItem ci) {
    switch (ci.type) {
      case CanvasItemType.image:
        return 'Image';
      case CanvasItemType.text:
        final t = ci.data as TextItem;
        return t.text.length > 14 ? '${t.text.substring(0, 14)}…' : t.text;
      case CanvasItemType.shape:
        final s = ci.data as ShapeItem;
        return s.type.name[0].toUpperCase() + s.type.name.substring(1);

      case CanvasItemType.emoji:
        final e = ci.data as EmojiItem;
        return 'Emoji ${e.emoji}';
      default:
        return 'Item';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Display top-first (reversed)
    final displayed = canvasItems.reversed.toList();

    return Container(
      width: 240,
      constraints: const BoxConstraints(maxHeight: 480),
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: _kPanel,
        borderRadius: BorderRadius.all(Radius.circular(14)),
        boxShadow: [BoxShadow(color: Color(0x55000000), blurRadius: 14)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(context),
          const SizedBox(height: 8),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 6),

          // ── Item stack (draggable) ──────────────────────────────────────
          if (canvasItems.isNotEmpty)
            Flexible(
              child: ReorderableListView.builder(
                shrinkWrap: true,
                itemCount: displayed.length,
                onReorder: (oldIdx, newIdx) {
                  if (newIdx > oldIdx) newIdx--;
                  // Convert back from reversed indices to real indices
                  final realOld = canvasItems.length - 1 - oldIdx;
                  final realNew = canvasItems.length - 1 - newIdx;
                  final updated = List<CanvasItem>.from(canvasItems);
                  final item = updated.removeAt(realOld);
                  updated.insert(realNew, item);
                  onReorder(updated);
                },
                itemBuilder: (ctx, i) {
                  final item = displayed[i];
                  final realIdx = canvasItems.indexOf(item);
                  final isTop = realIdx == canvasItems.length - 1;
                  final isBottom = realIdx == 0;
                  return _ItemRow(
                    key: ValueKey(_keyFor(item)),
                    item: item,
                    isTop: isTop,
                    isBottom: isBottom,
                    onBringToFront: () => onBringToFront(item),
                    onSendToBack: () => onSendToBack(item),
                    onBringForward: () => onBringForward(item),
                    onSendBackward: () => onSendBackward(item),
                    onDelete: () => onDeleteItem(item),
                  );
                },
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No items on canvas yet',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 6),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 8),

          // ── Layer tabs ────────────────────────────────────────────────
          _LayerTabBar(
            layers: layers,
            activeIndex: activeIndex,
            onSelect: onSelect,
            onAdd: onAdd,
            onToggleVisibility: onToggleVisibility,
            onDelete: onDelete,
            onRename: (i, name) => onRename(i, name),
          ),
        ],
      ),
    );
  }

  static String _keyFor(CanvasItem ci) {
    switch (ci.type) {
      case CanvasItemType.image:
        return (ci.data as ImageItem).id;
      case CanvasItemType.text:
        return (ci.data as TextItem).id;
      case CanvasItemType.shape:
        return (ci.data as ShapeItem).id;
      case CanvasItemType.emoji:
        return (ci.data as EmojiItem).id;
      default:
        return ci.hashCode.toString();
    }
  }

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Layers & Order',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: onClose,
          child: const Icon(Icons.close, color: Colors.grey, size: 16),
        ),
      ],
    );
  }
}

// ── Single item row ──────────────────────────────────────────────────────────
class _ItemRow extends StatelessWidget {
  final CanvasItem item;
  final bool isTop;
  final bool isBottom;
  final VoidCallback onBringToFront;
  final VoidCallback onSendToBack;
  final VoidCallback onBringForward;
  final VoidCallback onSendBackward;
  final VoidCallback onDelete;

  const _ItemRow({
    super.key,
    required this.item,
    required this.isTop,
    required this.isBottom,
    required this.onBringToFront,
    required this.onSendToBack,
    required this.onBringForward,
    required this.onSendBackward,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const BoxDecoration(
        color: _kWhite10,
        borderRadius: BorderRadius.all(Radius.circular(9)),
      ),
      child: Row(
        children: [
          // Drag handle
          const Icon(Icons.drag_indicator, color: Colors.grey, size: 16),
          const SizedBox(width: 6),

          // Type icon
          Icon(LayerPanel._iconFor(item), color: _kOrange, size: 16),
          const SizedBox(width: 6),

          // Label
          Expanded(
            child: Text(
              LayerPanel._labelFor(item),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // ── Arrow buttons ─────────────────────────────────────────────
          _iconBtn(
            Icons.vertical_align_top,
            'Bring to Front',
            isTop ? null : onBringToFront,
          ),
          _iconBtn(
            Icons.keyboard_arrow_up,
            'Bring Forward',
            isTop ? null : onBringForward,
          ),
          _iconBtn(
            Icons.keyboard_arrow_down,
            'Send Backward',
            isBottom ? null : onSendBackward,
          ),
          _iconBtn(
            Icons.vertical_align_bottom,
            'Send to Back',
            isBottom ? null : onSendToBack,
          ),
          _iconBtn(
            Icons.delete_outline,
            'Delete',
            onDelete,
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(
    IconData icon,
    String tooltip,
    VoidCallback? onTap, {
    Color color = Colors.grey,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            icon,
            size: 15,
            color: onTap == null ? Colors.white12 : color,
          ),
        ),
      ),
    );
  }
}

class _LayerTabBar extends StatelessWidget {
  final List<LayerData> layers;
  final int activeIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;
  final ValueChanged<int> onToggleVisibility;
  final ValueChanged<int> onDelete;
  final void Function(int, String) onRename;

  const _LayerTabBar({
    required this.layers,
    required this.activeIndex,
    required this.onSelect,
    required this.onAdd,
    required this.onToggleVisibility,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Text(
              'Layers',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: const BoxDecoration(
                  color: _kOrange,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 13),
                    SizedBox(width: 3),
                    Text(
                      'Add',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(layers.length, (i) {
              final active = activeIndex == i;
              return GestureDetector(
                onTap: () => onSelect(i),
                onLongPress: () => _showLayerOptions(context, i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: active ? _kOrange : _kWhite10,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    border: Border.all(
                      color: active ? _kOrange : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        layers[i].visible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        size: 12,
                        color: active ? Colors.white : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        layers[i].name,
                        style: TextStyle(
                          color: active ? Colors.white : Colors.grey,
                          fontSize: 12,
                          fontWeight: active
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Long-press a layer tab for options',
          style: TextStyle(color: Colors.grey, fontSize: 10),
        ),
      ],
    );
  }

  void _showLayerOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              layers[index].name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(
                layers[index].visible ? Icons.visibility_off : Icons.visibility,
                color: _kOrange,
              ),
              title: Text(
                layers[index].visible ? 'Hide Layer' : 'Show Layer',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                onToggleVisibility(index);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: _kOrange),
              title: const Text(
                'Rename',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, index);
              },
            ),
            if (layers.length > 1)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Delete Layer',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  onDelete(index);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, int index) {
    final ctrl = TextEditingController(text: layers[index].name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF333333),
        title: const Text(
          'Rename Layer',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _kOrange),
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty)
                onRename(index, ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Rename', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
