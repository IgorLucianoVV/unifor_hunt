import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class UserHeaderWidget extends StatelessWidget {
  final String nickname;
  final int totalPoints;
  final VoidCallback onUserSwitch;

  const UserHeaderWidget({
    Key? key,
    required this.nickname,
    required this.totalPoints,
    required this.onUserSwitch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.surfaceDark,
            AppTheme.surfaceDark.withValues(alpha: 0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark,
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Olá, ',
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textMediumEmphasis,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          nickname,
                          style:
                              AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'stars',
                        color: AppTheme.secondaryVariantDark,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '$totalPoints pontos totais',
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryVariantDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onUserSwitch,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: AppTheme.primaryDark.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'swap_horiz',
                      color: AppTheme.primaryDark,
                      size: 20,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Trocar',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
