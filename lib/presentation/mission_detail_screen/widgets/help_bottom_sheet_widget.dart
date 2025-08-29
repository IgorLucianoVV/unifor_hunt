import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class HelpBottomSheetWidget extends StatelessWidget {
  final String missionTitle;
  final List<String> helpTips;
  final String contactInfo;

  const HelpBottomSheetWidget({
    Key? key,
    required this.missionTitle,
    required this.helpTips,
    required this.contactInfo,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required String missionTitle,
    required List<String> helpTips,
    required String contactInfo,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HelpBottomSheetWidget(
        missionTitle: missionTitle,
        helpTips: helpTips,
        contactInfo: contactInfo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 80.h,
      ),
      decoration: BoxDecoration(
        color: AppTheme.dialogDark,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark,
            blurRadius: 16.0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.textMediumEmphasis.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 2.h),
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'help',
                  color: AppTheme.primaryDark,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Ajuda - $missionTitle',
                    style: GoogleFonts.orbitron(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textHighEmphasis,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: AppTheme.textMediumEmphasis.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.textMediumEmphasis,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tips Section
                  Text(
                    'Dicas Úteis',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.secondaryDark,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  ...helpTips.asMap().entries.map((entry) {
                    final index = entry.key;
                    final tip = entry.value;
                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 1.h),
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.dividerDark.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.secondaryDark.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.secondaryDark,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.secondaryDark,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              tip,
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.textHighEmphasis,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 2.h),
                  // Contact Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryDark.withValues(alpha: 0.1),
                          AppTheme.primaryDark.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryDark.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'contact_support',
                              color: AppTheme.primaryDark,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Ainda Precisa de Ajuda?',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          contactInfo,
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textMediumEmphasis,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}