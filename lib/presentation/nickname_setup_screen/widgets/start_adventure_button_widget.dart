import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class StartAdventureButtonWidget extends StatefulWidget {
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onPressed;

  const StartAdventureButtonWidget({
    super.key,
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<StartAdventureButtonWidget> createState() =>
      _StartAdventureButtonWidgetState();
}

class _StartAdventureButtonWidgetState extends State<StartAdventureButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    if (widget.isEnabled) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StartAdventureButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled && !oldWidget.isEnabled) {
      _glowController.repeat(reverse: true);
    } else if (!widget.isEnabled && oldWidget.isEnabled) {
      _glowController.stop();
      _glowController.reset();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isEnabled || widget.isLoading) return;

    HapticFeedback.mediumImpact();
    setState(() => _isPressed = true);

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() => _isPressed = false);
        widget.onPressed();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: double.infinity,
            height: 7.h,
            decoration: AppTheme.gamingButtonDecoration(
              backgroundColor: widget.isEnabled
                  ? AppTheme.darkTheme.colorScheme.primary
                  : AppTheme.darkTheme.colorScheme.surface,
              isPressed: _isPressed,
              hasGlow: widget.isEnabled && !widget.isLoading,
            ).copyWith(
              boxShadow: widget.isEnabled && !widget.isLoading
                  ? [
                      AppTheme.glowEffect(
                        color: AppTheme.darkTheme.colorScheme.primary,
                        blurRadius: 15.0 * _glowAnimation.value,
                        spreadRadius: 2.0,
                      ),
                      BoxShadow(
                        color: AppTheme.shadowDark,
                        blurRadius: _isPressed ? 2.0 : 4.0,
                        offset: Offset(0, _isPressed ? 1.0 : 2.0),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppTheme.shadowDark,
                        blurRadius: 2.0,
                        offset: const Offset(0, 1.0),
                      ),
                    ],
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 6.w,
                      height: 6.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.darkTheme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'play_arrow',
                          color: widget.isEnabled
                              ? AppTheme.darkTheme.colorScheme.onPrimary
                              : AppTheme.textMediumEmphasis,
                          size: 6.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Iniciar Aventura',
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: widget.isEnabled
                                ? AppTheme.darkTheme.colorScheme.onPrimary
                                : AppTheme.textMediumEmphasis,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
