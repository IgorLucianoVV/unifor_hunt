import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class TypewriterClueWidget extends StatefulWidget {
  final String clueText;
  final String? hintText;

  const TypewriterClueWidget({
    Key? key,
    required this.clueText,
    this.hintText,
  }) : super(key: key);

  @override
  State<TypewriterClueWidget> createState() => _TypewriterClueWidgetState();
}

class _TypewriterClueWidgetState extends State<TypewriterClueWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _characterCount;
  String _displayedText = '';
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: widget.clueText.length * 50),
      vsync: this,
    );

    _characterCount = IntTween(
      begin: 0,
      end: widget.clueText.length,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _characterCount.addListener(() {
      setState(() {
        _displayedText = widget.clueText.substring(0, _characterCount.value);
      });
    });

    _startTypewriterAnimation();
  }

  void _startTypewriterAnimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.cardDark,
            AppTheme.cardDark.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentGlow.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark,
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'lightbulb',
                color: AppTheme.secondaryVariantDark,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Pista Atual',
                style: GoogleFonts.orbitron(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondaryVariantDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          GestureDetector(
            onLongPress: () {
              // Enable text selection for accessibility
            },
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 12.h),
              child: SelectableText(
                _displayedText,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textHighEmphasis,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (_characterCount.value == widget.clueText.length) ...[
            SizedBox(height: 2.h),
            if (widget.hintText != null && widget.hintText!.isNotEmpty) ...[
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showHint = !_showHint;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryDark.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: _showHint ? 'visibility_off' : 'visibility',
                        color: AppTheme.primaryDark,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        _showHint ? 'Ocultar Dica' : 'Ver Dica',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showHint) ...[
                SizedBox(height: 1.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryDark.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.hintText!,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textMediumEmphasis,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }
}