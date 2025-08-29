import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class MissionProgressWidget extends StatelessWidget {
  final int currentClue;
  final int totalClues;
  final List<bool> completedClues;

  const MissionProgressWidget({
    Key? key,
    required this.currentClue,
    required this.totalClues,
    required this.completedClues,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.dividerDark.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              Text(
                '${completedClues.where((completed) => completed).length}/$totalClues',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondaryDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            height: 0.8.h,
            decoration: BoxDecoration(
              color: AppTheme.textDisabled,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor:
                  completedClues.where((completed) => completed).length /
                      totalClues,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.secondaryDark,
                      AppTheme.primaryDark,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    AppTheme.glowEffect(
                      color: AppTheme.secondaryDark,
                      blurRadius: 4.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: List.generate(totalClues, (index) {
              final isCompleted =
                  index < completedClues.length && completedClues[index];
              final isCurrent = index == currentClue - 1;

              return Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.secondaryDark
                      : isCurrent
                          ? AppTheme.primaryDark.withValues(alpha: 0.3)
                          : AppTheme.textDisabled.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrent
                        ? AppTheme.primaryDark
                        : isCompleted
                            ? AppTheme.secondaryDark
                            : AppTheme.textDisabled,
                    width: isCurrent ? 2 : 1,
                  ),
                  boxShadow: isCompleted || isCurrent
                      ? [
                          AppTheme.glowEffect(
                            color: isCompleted
                                ? AppTheme.secondaryDark
                                : AppTheme.primaryDark,
                            blurRadius: 6.0,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? CustomIconWidget(
                          iconName: 'check',
                          color: AppTheme.onSecondaryDark,
                          size: 16,
                        )
                      : Text(
                          '${index + 1}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: isCurrent
                                ? AppTheme.primaryDark
                                : AppTheme.textMediumEmphasis,
                          ),
                        ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}