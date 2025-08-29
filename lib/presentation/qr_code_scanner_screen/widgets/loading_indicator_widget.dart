import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LoadingIndicatorWidget extends StatefulWidget {
  final String message;

  const LoadingIndicatorWidget({
    super.key,
    this.message = 'Validando QR Code...',
  });

  @override
  State<LoadingIndicatorWidget> createState() => _LoadingIndicatorWidgetState();
}

class _LoadingIndicatorWidgetState extends State<LoadingIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.backgroundDark.withValues(alpha: 0.9),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppTheme.dialogDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryDark.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryDark.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated loading indicator
              AnimatedBuilder(
                animation:
                    Listenable.merge([_rotationAnimation, _pulseAnimation]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value * 2 * 3.14159,
                      child: Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryDark,
                              AppTheme.primaryVariantDark,
                              AppTheme.accentGlow,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.primaryDark.withValues(alpha: 0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 15.w,
                            height: 15.w,
                            decoration: BoxDecoration(
                              color: AppTheme.dialogDark,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: CustomIconWidget(
                                iconName: 'qr_code_scanner',
                                color: AppTheme.primaryDark,
                                size: 8.w,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 4.h),

              // Loading message
              Text(
                widget.message,
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textHighEmphasis,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 2.h),

              // Progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      final delay = index * 0.3;
                      final progress =
                          (_rotationController.value + delay) % 1.0;
                      final opacity =
                          progress < 0.5 ? progress * 2 : (1.0 - progress) * 2;

                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 1.w),
                        width: 2.w,
                        height: 2.w,
                        decoration: BoxDecoration(
                          color:
                              AppTheme.primaryDark.withValues(alpha: opacity),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  );
                }),
              ),

              SizedBox(height: 3.h),

              // Status text
              Text(
                'Aguarde um momento...',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMediumEmphasis,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
