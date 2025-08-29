import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/app_export.dart';

class PointsCounterWidget extends StatefulWidget {
  final int targetPoints;
  final bool isAnimating;
  final VoidCallback? onCountComplete;

  const PointsCounterWidget({
    super.key,
    required this.targetPoints,
    required this.isAnimating,
    this.onCountComplete,
  });

  @override
  State<PointsCounterWidget> createState() => _PointsCounterWidgetState();
}

class _PointsCounterWidgetState extends State<PointsCounterWidget>
    with TickerProviderStateMixin {
  late AnimationController _countController;
  late Animation<int> _countAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _countController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _countAnimation = IntTween(
      begin: 0,
      end: widget.targetPoints,
    ).animate(CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    ));

    _countAnimation.addListener(() {
      if (_countAnimation.value > 0 && _countAnimation.value % 10 == 0) {
        HapticFeedback.lightImpact();
      }
    });

    _countController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.mediumImpact();
        _pulseController.forward().then((_) {
          _pulseController.reverse();
          widget.onCountComplete?.call();
        });
      }
    });

    if (widget.isAnimating) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _countController.forward();
      });
    }
  }

  @override
  void didUpdateWidget(PointsCounterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !oldWidget.isAnimating) {
      _countController.reset();
      Future.delayed(const Duration(milliseconds: 800), () {
        _countController.forward();
      });
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_countAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
                  AppTheme.accentGlow.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'stars',
                  color: AppTheme.secondaryVariantLight,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  '+${_countAnimation.value}',
                  style: GoogleFonts.orbitron(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textHighEmphasis,
                    shadows: [
                      Shadow(
                        color: AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 1.w),
                Text(
                  'pontos',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textMediumEmphasis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}