import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class MissionHeaderWidget extends StatelessWidget {
  final String missionTitle;
  final int currentClue;
  final int totalClues;
  final int points;

  const MissionHeaderWidget({
    Key? key,
    required this.missionTitle,
    required this.currentClue,
    required this.totalClues,
    required this.points,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.9),
            AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          AppTheme.glowEffect(
            color: AppTheme.accentGlow,
            blurRadius: 12.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            missionTitle,
            style: GoogleFonts.orbitron(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textHighEmphasis,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryDark,
                    width: 1,
                  ),
                ),
                child: Text(
                  'Pista $currentClue de $totalClues',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryDark.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.secondaryDark,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'stars',
                      color: AppTheme.secondaryDark,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '$points pts',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}