import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_screen.dart';

/// Branded launch screen with theme-aware colors, logo, and a short intro animation.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.displayDuration = const Duration(milliseconds: 2400),
  });

  /// How long the splash stays visible before navigating to [HomeScreen].
  ///
  /// Tests pass [Duration.zero] to skip the wait.
  final Duration displayDuration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.72, curve: Curves.easeOutBack),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.38, 0.88, curve: Curves.easeOut),
      ),
    );
    _glowPulse = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    if (widget.displayDuration > Duration.zero) {
      await Future<void>.delayed(widget.displayDuration);
    }
    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 520),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const HomeScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.darkBackground,
                    AppColors.darkSurface,
                    AppColors.darkBackground,
                  ]
                : [
                    AppColors.background,
                    AppColors.primaryContainer.withValues(alpha: 0.65),
                    AppColors.background,
                  ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _PixelGridPainter(
                    color: primary.withValues(alpha: isDark ? 0.14 : 0.18),
                    phase: _controller.value,
                  ),
                );
              },
            ),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: child,
                        ),
                      );
                    },
                    child: _SplashLogo(
                      glowStrength: _glowPulse,
                      isDark: isDark,
                      primary: primary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacity.value,
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          AppConstants.appName,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          'Design · Export · Create',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return Opacity(
                        opacity: _textOpacity.value,
                        child: SizedBox(
                          width: 148,
                          child: LinearProgressIndicator(
                            minHeight: 3,
                            borderRadius: BorderRadius.circular(999),
                            backgroundColor: primary.withValues(alpha: 0.18),
                            valueColor: AlwaysStoppedAnimation<Color>(primary),
                            value: _controller.value.clamp(0.08, 1.0),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo({
    required this.glowStrength,
    required this.isDark,
    required this.primary,
  });

  final Animation<double> glowStrength;
  final bool isDark;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowStrength,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.28 * glowStrength.value),
                blurRadius: 36 * glowStrength.value,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? 0.45 : 0.12,
                ),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.asset(
          'assets/icon/app_icon.png',
          width: 128,
          height: 128,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// Subtle animated pixel grid that reinforces the app's motif.
class _PixelGridPainter extends CustomPainter {
  const _PixelGridPainter({
    required this.color,
    required this.phase,
  });

  final Color color;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    const cell = 18.0;
    final paint = Paint()..color = color;
    final cols = (size.width / cell).ceil() + 1;
    final rows = (size.height / cell).ceil() + 1;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final wave = math.sin((col + row) * 0.45 + phase * math.pi * 2);
        final alpha = 0.35 + (wave + 1) * 0.22;
        paint.color = color.withValues(alpha: color.a * alpha);
        final rect = Rect.fromLTWH(col * cell, row * cell, cell - 2, cell - 2);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PixelGridPainter oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.color != color;
  }
}
