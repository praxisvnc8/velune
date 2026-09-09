import 'package:flutter/material.dart';

/// VELUNE Palette: Deep, calm, minimal, elegant, and mysterious.
abstract class AppColors {
  // Backgrounds - Obsidian, Deep Void & Slate
  static const Color background = Color(0FF08090C);
  static const Color surface = Color(0FF12141C);
  static const Color surfaceElevated = Color(0FF181B26);
  static const Color card = Color(0FF141722);
  static const Color cardHover = Color(0FF1C202E);

  // Accents - Champagne Gold, Muted Bronze & Celestial Platinum
  static const Color accentGold = Color(0FFE2C97F);
  static const Color accentGoldMuted = Color(0FF9A8550);
  static const Color accentChampagne = Color(0FFF1E5C8);
  static const Color accentSilver = Color(0FFE0E2EC);
  static const Color accentPlatinum = Color(0FF989EAF);

  // Text Colors
  static const Color textPrimary = Color(0FFF8F9FA);
  static const Color textSecondary = Color(0xFFA0A5B5);
  static const Color textMuted = Color(0FF60667A);

  // Borders & Dividers
  static const Color border = Color(0FF1E2230);
  static const Color borderFocused = Color(0FFE2C97F);
  static const Color divider = Color(0FF181B28);

  // Status & Subtle Feedback
  static const Color error = Color(0FFE57373);
  static const Color success = Color(0FF81C784);
  static const Color warning = Color(0FFFFB74D);
}
