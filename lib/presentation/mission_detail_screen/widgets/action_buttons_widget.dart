import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onScanQRCode;
  final VoidCallback onNeedHelp;
  final bool isLoading;

  const ActionButtonsWidget({
    Key? key,
    required this.onScanQRCode,
    required this.onNeedHelp,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          // Primary Scan QR Code Button
          GestureDetector(
            onTap: isLoading
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    onScanQRCode();
                  },
            child: Container(
              width: double.infinity,
              height: 7.h,
              decoration: AppTheme.gamingButtonDecoration(
                backgroundColor: AppTheme.primaryDark,
                hasGlow: true,
                isPressed: false,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: isLoading
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          onScanQRCode();
                        },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLoading)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.onPrimaryDark,
                              ),
                            ),
                          )
                        else
                          CustomIconWidget(
                            iconName: 'qr_code_scanner',
                            color: AppTheme.onPrimaryDark,
                            size: 24,
                          ),
                        SizedBox(width: 3.w),
                        Text(
                          isLoading ? 'Carregando...' : 'Escanear Código QR',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onPrimaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          // Secondary Need Help Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onNeedHelp();
            },
            child: Container(
              width: double.infinity,
              height: 6.h,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.textMediumEmphasis.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onNeedHelp();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'help_outline',
                          color: AppTheme.textMediumEmphasis,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Precisa de Ajuda?',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textMediumEmphasis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}