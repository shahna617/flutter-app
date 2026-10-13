/// Strict 4/8 grid spacing and radius system defined in DESIGN.md sections 4 & 5.
abstract final class AppSpacing {
  // Strict 4/8 grid scale (allowed spacing values ONLY)
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;

  // Semantic layout spacing
  static const double screenHorizontal = s20;
  static const double sectionGap = s16;
  static const double cardPadding = s16;
  static const double cardInnerGap = s12;
  static const double topPaddingBelowSafeArea = s16;
  static const double scrollBottomPadding = 120.0;

  // Component dimensions
  static const double bottomNavHeight = 68.0;
  static const double bottomNavItemHeight = 56.0;
  static const double buttonHeight = 52.0;
  static const double minTapTarget = 44.0;
}

/// Shape and radius tokens from DESIGN.md section 5.
abstract final class AppRadius {
  static const double card = 24.0;
  static const double inner = 16.0;
  static const double pill = 999.0;
}
