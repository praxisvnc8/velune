import 'package:flutter/material.dart';

/// VELUNE Palette: Deep, calm, minimal, elegant, and mysterious.
abstract class AppColors {
  // Backgrounds - Obsidian, Deep Void & Slate
  static const Color background = Color(0xFF08090C);
  static const Color surface = Color(0xFF12141C);
  static const Color surfaceVariant = Color(0xFF161922);
  static const Color surfaceElevated = Color(0xFF181B26);
  static const Color card = Color(0xFF141722);
  static const Color cardHover = Color(0xFF1C202E);

  // Accents - Champagne Gold, Muted Bronze & Celestial Platinum
  static const Color accentGold = Color(0xFFE2C97F);
  static const Color accentGoldMuted = Color(0xFF9A8550);
  static const Color accentChampagne = Color(0xFFF1E5C8);
  static const Color accentSilver = Color(0xFFE0E2EC);
  static const Color accentPlatinum = Color(0xFF989EAF);

  // Text Colors
  static const Color textPrimary = Color(0xFFF8F9FA);
  static const Color textSecondary = Color(0xFFA0A5B5);
  static const Color textMuted = Color(0xFF60667A);

  // Borders & Dividers
  static const Color border = Color(0xFF1E2230);
  static const Color borderFocused = Color(0xFFE2C97F);
  static const Color divider = Color(0xFF181B28);

  // Status & Subtle Feedback
  static const Color error = Color(0xFFE57373);
  static const Color success = Color(0xFF81C784);
  static const Color warning = Color(0xFFFFB74D);
}
