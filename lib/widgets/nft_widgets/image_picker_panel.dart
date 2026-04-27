// lib/widgets/nft_widgets/image_picker_panel.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:nft_create/providers/nft_creator_provider.dart';

const kOrange = Color(0xFFF5A623);
const kPanel = Color(0xFF1E1E1E);

class ImagePickerPanel extends StatelessWidget {
  final void Function(File file) onImageSelected;
  final VoidCallback onClose;

  const ImagePickerPanel({
    super.key,
    required this.onImageSelected,
    required this.onClose,
  });

  Future<void> _pick(BuildContext context, ImageSource source) async {
    // ── 1. Capture the provider reference BEFORE closing the panel ──────────
    //    Once onClose() fires, this widget is removed from the tree and
    //    context.read() would throw. Grab the provider pointer now while
    //    context is still valid.
    final provider = context.read<NFTCreatorProvider>();

    // ── 2. Close the panel so it doesn't sit on top of the camera UI ────────
    onClose();

    // ── 3. Open picker ───────────────────────────────────────────────────────
    final picker = ImagePicker();
    XFile? picked;
    try {
      picked = await picker.pickImage(source: source, imageQuality: 90);
    } catch (e) {
      debugPrint('ImagePicker error: $e');
      return;
    }

    if (picked == null) return;

    if (source == ImageSource.camera) {
      // ── Camera: read bytes immediately – temp path can vanish after return ─
      Uint8List bytes;
      try {
        bytes = await picked.readAsBytes();
      } catch (e) {
        debugPrint('Failed to read camera bytes: $e');
        return;
      }

      if (bytes.isEmpty) {
        debugPrint('Camera returned empty bytes – aborting');
        return;
      }

      // Use the pre-captured provider reference — no context needed here,
      // so there is zero risk of a "context used after dispose" crash.
      provider.addImageFromBytes(
        bytes,
        'camera_${DateTime.now().millisecondsSinceEpoch}',
      );
    } else {
      // ── Gallery: file path is stable, use the existing File flow ──────────
      onImageSelected(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Image',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close, color: Colors.grey, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Gallery ────────────────────────────────────────────────────────
          _PickerOption(
            icon: Icons.photo_library_outlined,
            label: 'Gallery',
            onTap: () => _pick(context, ImageSource.gallery),
          ),
          const SizedBox(height: 8),

          // ── Camera ─────────────────────────────────────────────────────────
          _PickerOption(
            icon: Icons.camera_alt_outlined,
            label: 'Camera',
            onTap: () => _pick(context, ImageSource.camera),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: kOrange, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
