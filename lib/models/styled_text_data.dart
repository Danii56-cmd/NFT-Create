// lib/models/styled_text_data.dart

import 'package:flutter/material.dart';
import 'package:nft_create/enums.dart';

class StyledTextData {
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final TextEffect effect;
  final Color effectColor;

  const StyledTextData({
    required this.text,
    required this.color,
    required this.fontSize,
    this.fontWeight = FontWeight.normal,
    this.effect = TextEffect.none,
    this.effectColor = Colors.black,
  });

  StyledTextData copyWith({
    String? text,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    TextEffect? effect,
    Color? effectColor,
  }) {
    return StyledTextData(
      text: text ?? this.text,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      effect: effect ?? this.effect,
      effectColor: effectColor ?? this.effectColor,
    );
  }

  @override
  bool operator ==(Object o) =>
      o is StyledTextData &&
      o.text == text &&
      o.color == color &&
      o.fontSize == fontSize &&
      o.fontWeight == fontWeight &&
      o.effect == effect &&
      o.effectColor == effectColor;

  @override
  int get hashCode =>
      Object.hash(text, color, fontSize, fontWeight, effect, effectColor);
}
