// ─────────────────────────────────────────────────────────────────────────────
// styled_text_data.dart
// Data model for a text element that has been placed on the canvas
// with an optional visual effect (shadow / outline / glow).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

/// The four visual effects a styled text item can have.
enum TextEffect { none, shadow, outline, glow }

/// Immutable snapshot of a styled text item.
/// Stored in the screen's _styledTexts list and passed down to
/// [_DraggableStyledText] for rendering.
class StyledTextData {
  final String text;
  final Color color;
  final double fontSize;
  final TextEffect effect;
  final Color effectColor; // color used by shadow / outline / glow
  final FontWeight fontWeight;

  const StyledTextData({
    required this.text,
    required this.color,
    this.fontSize = 28,
    this.effect = TextEffect.none,
    this.effectColor = Colors.black,
    this.fontWeight = FontWeight.bold,
  });
}
