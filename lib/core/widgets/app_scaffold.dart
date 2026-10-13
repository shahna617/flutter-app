import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// App scaffold with gradient background, glow circles, and fixed bottom navigation.
/// Implements requirements from DESIGN.md sections 2, 7 & 8.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.header,
    required this.body,
    this.bottomNavigationBar,
    this.scrollable = true,
  });

  /// Optional header widget (e.g. [AppHeader]) placed within the safe area.
  final Widget? header;

  /// Main screen content widget.
  final Widget body;

  /// Floating glass navigation bar placed fixed outside the scroll view.
  final Widget? bottomNavigationBar;

  /// Whether the body should be wrapped inside a SingleChildScrollView. Defaults to true.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Screen background: gradient #F6F8F6 to #EEF3EF to #DCE7DE (160 degrees)
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.35, -1.0),
                  end: Alignment(0.35, 1.0),
                  colors: [
                    AppColors.background,
                    AppColors.backgroundGradientMid,
                    AppColors.backgroundGradientEnd,
                  ],
                ),
              ),
            ),
          ),

          // 2. Glow circles behind content (blur 42)
          // Glow A (top right, 30% opacity)
          Positioned(
            top: -40,
            right: -40,
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 42, sigmaY: 42),
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.glowA.withValues(alpha: 0.30),
                  ),
                ),
              ),
            ),
          ),

          // Glow B (mid left, 35% opacity)
          Positioned(
            top: 260,
            left: -60,
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 42, sigmaY: 42),
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.glowB.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ),

          // 3. Foreground content
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (header != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: header!,
                  ),
                Expanded(
                  child: scrollable
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenHorizontal,
                            AppSpacing.topPaddingBelowSafeArea,
                            AppSpacing.screenHorizontal,
                            AppSpacing.scrollBottomPadding,
                          ),
                          child: body,
                        )
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenHorizontal,
                            AppSpacing.topPaddingBelowSafeArea,
                            AppSpacing.screenHorizontal,
                            AppSpacing.scrollBottomPadding,
                          ),
                          child: body,
                        ),
                ),
              ],
            ),
          ),

          // 4. Fixed Bottom bar outside the scroll view
          if (bottomNavigationBar != null)
            SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: bottomNavigationBar!,
              ),
            ),
        ],
      ),
    );
  }
}
