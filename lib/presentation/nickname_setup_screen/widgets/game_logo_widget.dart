import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class GameLogoWidget extends StatefulWidget {
  const GameLogoWidget({super.key});

  @override
  State<GameLogoWidget> createState() => _GameLogoWidgetState();
}

class _GameLogoWidgetState extends State<GameLogoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.darkTheme.colorScheme.primary,
                  AppTheme.darkTheme.colorScheme.primaryContainer,
                  AppTheme.darkTheme.colorScheme.tertiary,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
              boxShadow: [
                AppTheme.glowEffect(
                  color: AppTheme.darkTheme.colorScheme.primary,
                  blurRadius: 15.0,
                  spreadRadius: 3.0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'UH',
                style: AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(
                  color: AppTheme.darkTheme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 18.sp,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
