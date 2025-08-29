import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onRefresh;

  const EmptyStateWidget({
    Key? key,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryDark.withValues(alpha: 0.3),
                    AppTheme.primaryVariantDark.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.w),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryDark.withValues(alpha: 0.2),
                    blurRadius: 20.0,
                    spreadRadius: 5.0,
                    offset: Offset.zero,
                  ),
                ],
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'explore',
                  color: AppTheme.primaryDark,
                  size: 15.w,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Nenhuma Missão Disponível',
              style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.textHighEmphasis,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Não há missões disponíveis no momento.\nTente novamente mais tarde ou verifique sua conexão.',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMediumEmphasis,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: CustomIconWidget(
                iconName: 'refresh',
                color: AppTheme.onPrimaryDark,
                size: 20,
              ),
              label: Text(
                'Tentar Novamente',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.onPrimaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDark,
                foregroundColor: AppTheme.onPrimaryDark,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 4.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
