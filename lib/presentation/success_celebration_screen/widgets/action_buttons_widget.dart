import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/app_export.dart';

class ActionButtonsWidget extends StatefulWidget {
  final bool isMissionComplete;
  final VoidCallback onContinuePressed;
  final VoidCallback onSharePressed;
  final bool isVisible;

  const ActionButtonsWidget({
    super.key,
    required this.isMissionComplete,
    required this.onContinuePressed,
    required this.onSharePressed,
    required this.isVisible,
  });

  @override
  State<ActionButtonsWidget> createState() => _ActionButtonsWidgetState();
}

class _ActionButtonsWidgetState extends State<ActionButtonsWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _primarySlideAnimation;
  late Animation<Offset> _secondarySlideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _primarySlideAnimation = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));

    _secondarySlideAnimation = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
    ));

    if (widget.isVisible) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        _slideController.forward();
      });
    }
  }

  @override
  void didUpdateWidget(ActionButtonsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        _slideController.forward();
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _handleContinuePressed() {
    HapticFeedback.mediumImpact();
    widget.onContinuePressed();
  }

  void _handleSharePressed() {
    HapticFeedback.lightImpact();
    widget.onSharePressed();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SlideTransition(
          position: _primarySlideAnimation,
          child: Container(
            width: 85.w,
            height: 7.h,
            child: ElevatedButton(
              onPressed: _handleContinuePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.primaryColor,
                foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
                elevation: 8,
                shadowColor:
                    AppTheme.lightTheme.primaryColor.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ).copyWith(
                overlayColor: WidgetStateProperty.all(
                  AppTheme.lightTheme.colorScheme.onPrimary
                      .withValues(alpha: 0.1),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.lightTheme.primaryColor,
                      AppTheme.accentGlow,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightTheme.primaryColor
                          .withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: widget.isMissionComplete
                            ? 'explore'
                            : 'arrow_forward',
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        size: 6.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        widget.isMissionComplete
                            ? 'Explorar Próxima Missão'
                            : 'Continuar Aventura',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 3.h),
        SlideTransition(
          position: _secondarySlideAnimation,
          child: Container(
            width: 85.w,
            height: 6.h,
            child: OutlinedButton(
              onPressed: _handleSharePressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.lightTheme.primaryColor,
                side: BorderSide(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.6),
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor:
                    AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
              ).copyWith(
                overlayColor: WidgetStateProperty.all(
                  AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'share',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Compartilhar Conquista',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}