import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/app_export.dart';

class ProgressSummaryWidget extends StatefulWidget {
  final int completedClues;
  final int totalClues;
  final bool isAnimating;
  final bool isMissionComplete;

  const ProgressSummaryWidget({
    super.key,
    required this.completedClues,
    required this.totalClues,
    required this.isAnimating,
    required this.isMissionComplete,
  });

  @override
  State<ProgressSummaryWidget> createState() => _ProgressSummaryWidgetState();
}

class _ProgressSummaryWidgetState extends State<ProgressSummaryWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    final previousProgress = widget.totalClues > 0
        ? (widget.completedClues - 1) / widget.totalClues
        : 0.0;
    final currentProgress =
        widget.totalClues > 0 ? widget.completedClues / widget.totalClues : 0.0;

    _progressAnimation = Tween<double>(
      begin: previousProgress,
      end: currentProgress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    if (widget.isAnimating) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        _slideController.forward();
        Future.delayed(const Duration(milliseconds: 400), () {
          _progressController.forward();
        });
      });
    }
  }

  @override
  void didUpdateWidget(ProgressSummaryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !oldWidget.isAnimating) {
      _slideController.reset();
      _progressController.reset();
      Future.delayed(const Duration(milliseconds: 1200), () {
        _slideController.forward();
        Future.delayed(const Duration(milliseconds: 400), () {
          _progressController.forward();
        });
      });
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: 85.w,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.cardDark.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowDark,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progresso da Missão',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textHighEmphasis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: widget.isMissionComplete
                        ? AppTheme.lightTheme.colorScheme.secondary
                            .withValues(alpha: 0.2)
                        : AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.isMissionComplete ? 'COMPLETA!' : 'EM PROGRESSO',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: widget.isMissionComplete
                          ? AppTheme.lightTheme.colorScheme.secondary
                          : AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'lightbulb',
                  color: AppTheme.secondaryVariantLight,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pistas Descobertas',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textMediumEmphasis,
                            ),
                          ),
                          Text(
                            '${widget.completedClues}/${widget.totalClues}',
                            style: GoogleFonts.orbitron(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textHighEmphasis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Container(
                            height: 1.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: AppTheme.textDisabled,
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _progressAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: LinearGradient(
                                    colors: widget.isMissionComplete
                                        ? [
                                            AppTheme.lightTheme.colorScheme
                                                .secondary,
                                            AppTheme.secondaryVariantLight,
                                          ]
                                        : [
                                            AppTheme.lightTheme.primaryColor,
                                            AppTheme.accentGlow,
                                          ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (widget.isMissionComplete
                                              ? AppTheme.lightTheme.colorScheme
                                                  .secondary
                                              : AppTheme
                                                  .lightTheme.primaryColor)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.isMissionComplete) ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.lightTheme.colorScheme.secondary
                          .withValues(alpha: 0.2),
                      AppTheme.secondaryVariantLight.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.secondary
                        .withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'emoji_events',
                      color: AppTheme.secondaryVariantLight,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Missão concluída com sucesso! Nova missão desbloqueada.',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textHighEmphasis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}