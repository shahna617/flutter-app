import 'package:flutter/material.dart';

/// Design color tokens defined in DESIGN.md section 2.
abstract final class AppColors {
  // Brand & Navigation
  static const Color primary = Color(0xFF1F5238);
  static const Color primarySoft = Color(0xFFDDE9E0);
  static const Color navActive = Color(0xFFD3E1D8);

  // Background & Gradient
  static const Color background = Color(0xFFF6F8F6);
  static const Color backgroundGradientMid = Color(0xFFEEF3EF);
  static const Color backgroundGradientEnd = Color(0xFFDCE7DE);

  // Typography
  static const Color textPrimary = Color(0xFF0F2A1D);
  static const Color textMuted = Color(0xFF52695B);

  // Borders & Accents
  static const Color border = Color(0xFFDCE5DF);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Background Glow circles (Section 2 & 7)
  static const Color glowA = Color(0xFF3F8A62);
  static const Color glowB = Color(0xFF7DB596);

  // Status Chips
  static const Color pendingBg = Color(0xFFF7E9C6);
  static const Color pendingText = Color(0xFF7A5A0B);

  static const Color inReviewBg = Color(0xFFD3E1D8);
  static const Color inReviewText = Color(0xFF1F5238);

  static const Color resolvedBg = Color(0xFFD6EFD9);
  static const Color resolvedText = Color(0xFF14532D);

  // Destructive Actions
  static const Color danger = Color(0xFFB42318);
}
