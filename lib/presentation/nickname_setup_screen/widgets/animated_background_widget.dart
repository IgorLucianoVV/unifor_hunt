import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AnimatedBackgroundWidget extends StatefulWidget {
  const AnimatedBackgroundWidget({super.key});

  @override
  State<AnimatedBackgroundWidget> createState() =>
      _AnimatedBackgroundWidgetState();
}

class _AnimatedBackgroundWidgetState extends State<AnimatedBackgroundWidget>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));
    _gradientController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkTheme.scaffoldBackgroundColor,
                AppTheme.darkTheme.colorScheme.surface,
                AppTheme.darkTheme.scaffoldBackgroundColor
                    .withValues(alpha: 0.8),
              ],
              stops: [
                0.0,
                _gradientAnimation.value,
                1.0,
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                AppTheme.glowEffect(
                  color: AppTheme.accentGlow,
                  blurRadius: 20.0 * _gradientAnimation.value,
                  spreadRadius: 2.0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
