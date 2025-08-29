import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OfflineIndicatorWidget extends StatelessWidget {
  final DateTime? lastUpdated;

  const OfflineIndicatorWidget({
    Key? key,
    this.lastUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: AppTheme.secondaryVariantDark.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppTheme.secondaryVariantDark.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'wifi_off',
            color: AppTheme.secondaryVariantDark,
            size: 20,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modo Offline',
                  style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.secondaryVariantDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (lastUpdated != null) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    'Última atualização: ${_formatDateTime(lastUpdated!)}',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMediumEmphasis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'agora mesmo';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h atrás';
    } else {
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    }
  }
}
