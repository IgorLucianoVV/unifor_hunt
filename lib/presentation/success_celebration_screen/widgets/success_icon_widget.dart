import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class SuccessIconWidget extends StatefulWidget {
  final bool isAnimating;

  const SuccessIconWidget({
    super.key,
    required this.isAnimating,
  });

  @override
  State<SuccessIconWidget> createState() => _SuccessIconWidgetState();
}

class _SuccessIconWidgetState extends State<SuccessIconWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    if (widget.isAnimating) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _glowController.repeat(reverse: true);
    });
  }

  @override
  void didUpdateWidget(SuccessIconWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !oldWidget.isAnimating) {
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightTheme.colorScheme.secondary,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.secondary.withValues(
                    alpha: 0.3 + (_glowAnimation.value * 0.4),
                  ),
                  blurRadius: 20 + (_glowAnimation.value * 20),
                  spreadRadius: 5 + (_glowAnimation.value * 10),
                ),
                BoxShadow(
                  color: AppTheme.accentGlow.withValues(
                    alpha: 0.2 + (_glowAnimation.value * 0.3),
                  ),
                  blurRadius: 30 + (_glowAnimation.value * 30),
                  spreadRadius: 10 + (_glowAnimation.value * 15),
                ),
              ],
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'check',
                color: AppTheme.lightTheme.colorScheme.onSecondary,
                size: 12.w,
              ),
            ),
          ),
        );
      },
    );
  }
}
